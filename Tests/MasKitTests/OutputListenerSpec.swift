//
//  OutputListenerSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/8/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

class OutputListenerSpec: QuickSpec {
    override func spec() {
        describe("output listener") {
            it("can intercept a single line written stdout") {
                let output = OutputListener()
                let expectedOutput = "hi there"

                print("hi there", terminator: "")

                expect(output.contents) == expectedOutput
            }
            it("can intercept multiple lines written stdout") {
                let output = OutputListener()
                let expectedOutput = """
                    hi there

                    """

                print("hi there")

                expect(output.contents) == expectedOutput
            }
        }
    }
}
