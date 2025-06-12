import XCTest

final class TipjeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func testOnboardingToAdminSuccessModal() {
        // Onboarding slides
        app.buttons["onboardingNextButton1"].tap()
        app.buttons["onboardingNextButton2"].tap()
        app.buttons["onboardingNextButton3"].tap()

        // Kids profile
        let kidNameField = app.textFields["kidNameField_0"]
        XCTAssertTrue(kidNameField.waitForExistence(timeout: 2))
        kidNameField.tap()
        kidNameField.typeText("Test Kid")
        app.buttons["kidsProfileNextButton"].tap()

        // Pin setup
        let pinFields = app.otherElements["pinInputFields"]
        XCTAssertTrue(pinFields.waitForExistence(timeout: 2))
        // Simulate entering 1-1-1-1 for pin (adjust if your UI uses separate fields)
        for _ in 0..<4 {
            app.keys["1"].tap()
        }
        app.buttons["pinSetupNextButton"].tap()

        // Admin tab: Add a rule
        app.buttons["addRuleButton"].tap()
        let ruleCell = app.otherElements.matching(identifier: "ruleCell_").firstMatch
        XCTAssertTrue(ruleCell.waitForExistence(timeout: 2))
        ruleCell.tap()
        app.buttons["saveRulesButton"].tap()

        // Switch to Chores tab and add a chore
        app.buttons["choresTabButton"].tap()
        app.buttons["addRuleButton"].tap() // If you have a separate addChoreButton, use that identifier
        let choreCell = app.otherElements.matching(identifier: "choreCell_").firstMatch
        XCTAssertTrue(choreCell.waitForExistence(timeout: 2))
        choreCell.tap()
        app.buttons["saveChoresButton"].tap()

        // Switch to Shop tab and add a reward
        app.buttons["shopTabButton"].tap()
        app.buttons["addRuleButton"].tap() // If you have a separate addRewardButton, use that identifier
        let rewardCell = app.otherElements.matching(identifier: "rewardCell_").firstMatch
        XCTAssertTrue(rewardCell.waitForExistence(timeout: 2))
        rewardCell.tap()
        app.buttons["saveRewardsButton"].tap()

        // Check for the success modal
        let successModal = app.otherElements["adminSuccessModal"]
        XCTAssertTrue(successModal.waitForExistence(timeout: 5), "Success modal should appear after adding at least one card to each tab.")

        // Optionally, dismiss the modal and check for admin lock
        // app.buttons["closeSuccessModalButton"].tap()
        // let pinEntry = app.otherElements["pinEntryView"]
        // XCTAssertTrue(pinEntry.waitForExistence(timeout: 5), "Admin should be locked after success modal is dismissed.")
    }
}
