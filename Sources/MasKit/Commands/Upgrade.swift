//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Foundation

/// Command which upgrades apps with new versions available in the Mac App Store.
public struct UpgradeCommand: CommandProtocol {
    public typealias Options = UpgradeOptions
    public let verb = "upgrade"
    public let function = "Upgrade outdated apps from the Mac App Store"

    private let appLibrary: AppLibrary
    private let storeSearch: StoreSearch

    /// Public initializer.
    public init() {
        self.init(appLibrary: MasAppLibrary())
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    /// - Parameter storeSearch: StoreSearch manager.
    init(appLibrary: AppLibrary = MasAppLibrary(), storeSearch: StoreSearch = MasStoreSearch()) {
        self.appLibrary = appLibrary
        self.storeSearch = storeSearch
    }

    /// Runs the command.
    public func run(_ options: Options) -> Result<Void, MASError> {
        let apps: [SoftwareProduct]
        do {
            apps = try findOutdatedApps(options)
        } catch {
            // Bubble up MASErrors
            return .failure(error as? MASError ?? .searchFailed)
        }

        guard apps.count > 0 else {
            printWarning("Nothing found to upgrade")
            return .success(())
        }

        print("Upgrading \(apps.count) outdated application\(apps.count > 1 ? "s" : ""):")
        print(apps.map { "\($0.appName) (\($0.bundleVersion))" }.joined(separator: ", "))

        var updatedAppCount = 0
        var failedUpgradeResults = [MASError]()
        for app in apps {
            if let upgradeResult = download(app.itemIdentifier.uint64Value) {
                failedUpgradeResults.append(upgradeResult)
            } else {
                updatedAppCount += 1
            }
        }

        switch failedUpgradeResults.count {
        case 0:
            if updatedAppCount == 0 {
                print("Everything is up-to-date")
            }
            return .success(())
        case 1:
            return .failure(failedUpgradeResults[0])
        default:
            return .failure(.downloadFailed(error: nil))
        }
    }

    private func findOutdatedApps(_ options: Options) throws -> [SoftwareProduct] {
        var apps: [SoftwareProduct]
        if options.apps.isEmpty {
            apps = appLibrary.installedApps
        } else {
            apps = options.apps.compactMap {
                if let appId = UInt64($0) {
                    // if argument a UInt64, lookup app by id using argument
                    return appLibrary.installedApp(forId: appId)
                } else {
                    // if argument not a UInt64, lookup app by name using argument
                    return appLibrary.installedApp(named: $0)
                }
            }
        }

        var outdated = [SoftwareProduct]()
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        for installedApp in apps {
            // only upgrade apps whose local version differs from the store version
            group.enter()
            storeSearch.lookup(app: installedApp.itemIdentifier.intValue) { result, _ in
                defer { group.leave() }

                if let storeApp = result, installedApp.isOutdatedWhenComparedTo(storeApp) {
                    semaphore.wait()
                    defer { semaphore.signal() }

                    outdated.append(installedApp)
                }
            }
        }

        group.wait()

        return outdated
    }
}

public struct UpgradeOptions: OptionsProtocol {
    let apps: [String]

    static func create(_ apps: [String]) -> UpgradeOptions {
        UpgradeOptions(apps: apps)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<UpgradeOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(defaultValue: [], usage: "app(s) to upgrade")
    }
}
