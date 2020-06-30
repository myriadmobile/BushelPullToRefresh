//
//  BushelRefresh_UITests.swift
//  BushelRefresh_UITests
//
//  Created by Alex (Work) on 6/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
//import BushelRefresh

class BushelRefresh_UITests: XCTestCase {

    // MARK: Setup
    override func setUp() {
        //As required by Fastlane
        continueAfterFailure = false
        let app = XCUIApplication() //TODO: Is this needed?
        app.launch()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    
    //
    //
    // NOTE: I'm having troubles writing good UI tests. Maybe continue this at a later date.
    //
    //
    func testOffsetAfterBeforeDragging() throws {
        let app = XCUIApplication()
        
        sleep(2)
        
        //Get table
        let table = app.tables.firstMatch
        
        //Get PTR
        let pullToRefreshView = table.otherElements["PullToRefreshView"]
        
        //Validate
        let ptrFrame = pullToRefreshView.frame
        print("HERE")
    }
    
    func testOffsetAfterSwipe() throws {
        let app = XCUIApplication()
        
        //Get table
        let table = app.tables.firstMatch
        
        //Get PTR
        let pullToRefreshView = table.otherElements["PullToRefreshView"]
        
        //Swipe Down
        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = table.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 72))
        start.press(forDuration: 0, thenDragTo: finish)
        
        //Validate
        let foo = pullToRefreshView.frame
        print("HERE")
    }
    
    func testOffsetAfterLoading() throws {
        
    }

}
