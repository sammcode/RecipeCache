//
//  HelpfulFunctionsTests.swift
//  RecipeTimerTests
//
//  Created by Sam McGarry on 2/7/21.
//  Copyright © 2021 Sam McGarry. All rights reserved.
//

import XCTest
@testable import RecipeCache

class HelpfulFunctionsTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testApplyMultiplier() {
        //Create different test case quantities and multipliers
        let testQuantity = "5 Tablespoons"
        let testMultiplier = "2.0"
        let testResult = HelpfulFunctions.applyMultiplier(quantity: testQuantity, multiplier: testMultiplier)
        
        let testQuantity1 = "5.8"
        let testMultiplier1 = "2.0"
        let testResult1 = HelpfulFunctions.applyMultiplier(quantity: testQuantity1, multiplier: testMultiplier1)
        
        let testQuantity2 = "Five"
        let testMultiplier2 = "2.0"
        let testResult2 = HelpfulFunctions.applyMultiplier(quantity: testQuantity2, multiplier: testMultiplier2)
        
        let testQuantity3 = "1/2 Teaspoon"
        let testMultiplier3 = "2.0"
        let testResult3 = HelpfulFunctions.applyMultiplier(quantity: testQuantity3, multiplier: testMultiplier3)
        
        let testQuantity4 = "Cups 10"
        let testMultiplier4 = "2.0"
        let testResult4 = HelpfulFunctions.applyMultiplier(quantity: testQuantity4, multiplier: testMultiplier4)
        
        //Check that the expected results are equal to the actual results
        XCTAssertEqual(testResult, "10 Tablespoons")
        XCTAssertEqual(testResult1, "11.6")
        XCTAssertEqual(testResult2, "Five x 2.0")
        XCTAssertEqual(testResult3, "1/2 Teaspoon x 2.0")
        XCTAssertEqual(testResult4, "20 Cups")
    }
    
    func testExtractDigits() {
        //Create different test quantities
        let testQuantity = "5 Tablespoons"
        let testResult = HelpfulFunctions.extractDigits(quantity: testQuantity)
        
        let testQuantity1 = "5.8"
        let testResult1 = HelpfulFunctions.extractDigits(quantity: testQuantity1)
        
        let testQuantity2 = "Five"
        let testResult2 = HelpfulFunctions.extractDigits(quantity: testQuantity2)
        
        let testQuantity3 = "1/2 Teaspoon"
        let testResult3 = HelpfulFunctions.extractDigits(quantity: testQuantity3)
        
        let testQuantity4 = "Cups 10"
        let testResult4 = HelpfulFunctions.extractDigits(quantity: testQuantity4)
        
        //Check that the expected results are equal to the actual results
        XCTAssertEqual(testResult, ["5", "Tablespoons"])
        XCTAssertEqual(testResult1, ["5.8", ""])
        XCTAssertEqual(testResult2, ["", "Five"])
        XCTAssertEqual(testResult3, ["", ""])
        XCTAssertEqual(testResult4, ["10", "Cups"])
        
    }

}
