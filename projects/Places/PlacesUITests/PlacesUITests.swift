//
//  PlacesUITests.swift
//  PlacesUITests
//
//  Created by Frans Glorie on 02/09/2026.
//

import XCTest

final class PlacesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddsAndDeletesCustomLocation() throws {
        let app = XCUIApplication()
        app.launch()

        let loadingIndicator = app.activityIndicators["LocationsLoadingIndicator"]
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.waitForNonExistence(timeout: 10))
        }

        app.buttons["AddLocation"].tap()

        let nameTextField = app.textFields["CustomLocationName"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 5))
        nameTextField.tap()
        nameTextField.typeText("Greenland")

        let latitudeTextField = app.textFields["CustomLocationLatitude"]
        latitudeTextField.tap()
        latitudeTextField.typeText("76.390857")

        let longitudeTextField = app.textFields["CustomLocationLongitude"]
        longitudeTextField.tap()
        longitudeTextField.typeText("-40.707943")

        app.buttons["Add"].tap()

        let greenlandRow = app.buttons["Greenland"]
        XCTAssertTrue(greenlandRow.waitForExistence(timeout: 5))

        greenlandRow.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertFalse(greenlandRow.waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
