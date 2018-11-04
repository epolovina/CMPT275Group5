//
//  TrackPointUITests.swift
//  TrackPointUITests
//
//  Created by Taylor Traviss on 2018-10-23.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import XCTest

class TrackPointUITests: XCTestCase {
    var sut: UIViewController!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = sut
        
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
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        app.buttons["Menu"].tap()
        XCTAssertTrue(app.staticTexts["Main Menu"].exists)
        app.buttons["Progress"].tap()
        XCTAssertTrue(app.staticTexts["Progress"].exists)
        
        
    }
    
    func testProfileToPopupToProgress(){
        
        
        let app = XCUIApplication()
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Enter Medication"].exists)
        XCTAssertTrue(app.staticTexts["Start Date"].exists)
        XCTAssertTrue(app.staticTexts["End Date"].exists)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        app.buttons["Progess"].tap()
        XCTAssertTrue(app.staticTexts["Progress"].exists)
        app.buttons["Share"].tap()
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        XCTAssertEqual(sut.presentedViewController?.title, "Alert")
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

