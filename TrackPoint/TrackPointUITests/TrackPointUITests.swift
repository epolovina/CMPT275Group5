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
    func testProfileToMenuToProgress(){
        
        let app = XCUIApplication()
        app.buttons["Profile"].tap()
        app.buttons["Menu"].tap()
        app.buttons["Progress"].tap()
        
        
    }
    
    func testProfileToPopupToProgress(){
        
        
        let app = XCUIApplication()
        app.buttons["Profile"].tap()
        app.buttons["Add"].tap()
       
    
        app.buttons["Save"].tap()
        app.buttons["Progess"].tap()
        app.buttons["Months"].tap()
        app.buttons["Share"].tap()
        app.buttons["Menu"].tap()
        
        
    }

    func testenuToProgress() {
        // Use recording to get started writing UI tests.
        
        let app = XCUIApplication()
        app.buttons["Progress"].tap()
        app.buttons["Menu"].tap()
                        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}

