//
//  TrackPointUITests.swift
//  TrackPointUITests
//
//  Created by Taylor Traviss on 2018-10-23.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import XCTest

class TrackPointUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    //scenario 1: menu -> profile -> menu
    
    func testScenario1() {
        let app = XCUIApplication()
        XCTAssertTrue(app.buttons["Profile"].exists)
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["Menu"].exists)
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        app.buttons["Menu"].tap()
        XCTAssertTrue(app.staticTexts["Main Menu"].exists)

    }
    
    //scenario 2: menu -> progress -> profile -> menu
    func testScenario2() {
        let app = XCUIApplication()
        XCTAssertTrue(app.buttons["Progress"].exists)
        app.buttons["Progress"].tap()
        XCTAssertTrue(app.staticTexts["Progress"].exists)
        XCTAssertTrue(app.buttons["Profile"].exists)
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        app.buttons["Menu"].tap()
        XCTAssertTrue(app.staticTexts["Main Menu"].exists)
    }
    

    
    
}

