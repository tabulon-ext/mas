//
//  NetworkManagerTests.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import XCTest

@testable import MasKit

class NetworkManagerTests: XCTestCase {
    func testSuccessfulAsyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        var response: Data?
        var error: Error?
        manager.loadData(from: url) {
            response = $0
            error = $1
        }

        XCTAssertEqual(response, data)
        XCTAssertNil(error)
    }

    func testSuccessfulSyncResponse() throws {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        let result = try manager.loadDataSync(from: url)
        XCTAssertEqual(result, data)
    }

    func testFailureAsyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = MASError.noData

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        var error: Error!
        manager.loadData(from: url) { error = $1 }
        guard let masError = error as? MASError else {
            XCTFail("Error is of unexpected type.")
            return
        }

        XCTAssertEqual(masError, MASError.noData)
    }

    func testFailureSyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = MASError.noData

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        XCTAssertThrowsError(try manager.loadDataSync(from: url)) { error in
            guard let error = error as? MASError else {
                XCTFail("Error is of unexpected type.")
                return
            }

            XCTAssertEqual(error, MASError.noData)
        }
    }
}
