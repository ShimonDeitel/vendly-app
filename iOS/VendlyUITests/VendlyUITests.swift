import XCTest

final class VendlyUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["entryTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        let amountField = app.textFields["entryAmountField"]
        amountField.tap()
        amountField.typeText("12.34")
        app.buttons["saveEntryButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<40 {
            app.buttons["addEntryButton"].tap()
            let titleField = app.textFields["entryTitleField"]
            if !titleField.waitForExistence(timeout: 1) { break }
            titleField.tap()
            titleField.typeText("Filler \(i)")
            app.textFields["entryAmountField"].tap()
            app.textFields["entryAmountField"].typeText("1")
            app.buttons["saveEntryButton"].tap()
        }
        app.buttons["addEntryButton"].tap()
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["entryTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Item / Price"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
