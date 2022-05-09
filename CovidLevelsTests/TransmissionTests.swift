//
//  TransmissionTests.swift
//  CovidLevelsTests
//
//  Created by Noah on 5/8/22.
//

import XCTest
@testable import CovidLevels

class TransmissionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequest() throws {
        
        let expectation = XCTestExpectation(description: "Request larimer county transmission data")
        
        TransmissionData.request(state: "Colorado", county: "Larimer County") { transmission in
            XCTAssertEqual(transmission.state, "Colorado")
            XCTAssertEqual(transmission.county, "Larimer County")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
