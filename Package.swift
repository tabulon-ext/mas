// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mas",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "mas",
            targets: ["mas"]
        ),
        .library(
            name: "MasKit",
            targets: ["MasKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.18.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.2"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "mas",
            dependencies: ["MasKit"],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ]),
            ]
        ),
        .target(
            name: "MasKit",
            dependencies: ["Commandant", "Version"],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ]),
            ],
            linkerSettings: [
                .linkedFramework("CommerceKit"),
                .linkedFramework("StoreFoundation"),
                .unsafeFlags(["-F", "/System/Library/PrivateFrameworks"]),
            ]
        ),
        .testTarget(
            name: "MasKitTests",
            dependencies: ["MasKit", "Nimble", "Quick"],
            resources: [.copy("JSON")],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ]),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
