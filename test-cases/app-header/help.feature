Feature: Help

  @ui @positive @smoke
  Scenario: Help icon-button renders in app header
    Given the app header is visible
    And the help icon-button (question-circle) is rendered
    When the page loads
    Then the help icon-button is displayed in the global header

  @ui @positive
  Scenario: Tooltip appears on hover over help icon
    Given the app header is visible
    And the help icon-button is rendered
    When the user hovers over the help icon-button
    Then a tooltip labelled "Help" appears anchored to the icon-button

  @ui @positive @smoke @gap
  Scenario: Clicking help icon triggers in-app Pendo asset (not new tab)
    Given the help icon-button is in its default state
    And no Pendo asset is currently visible
    When the user clicks the help icon-button
    Then the Pendo help asset is triggered and becomes visible in-app
    And the icon-button transitions to selected state
    And no new browser tab is opened

  @ui @positive
  Scenario: Other header overlays close when Pendo asset activates
    Given the help icon-button is in its default state
    And no Pendo asset is currently visible
    When the user clicks the help icon-button
    Then the Pendo help asset is triggered and becomes visible in-app
    And all other open header overlays close

  @ui @positive
  Scenario: Icon-button returns to default state when Pendo asset dismissed
    Given the Pendo help asset is currently visible
    When the user dismisses the Pendo asset
    Then the help icon-button returns to its default (non-selected) state

  @ui @positive @smoke
  Scenario: Second click toggles Pendo asset closed
    Given the Pendo help asset is visible
    And the icon-button is in selected state
    When the user clicks the help icon-button a second time
    Then the Pendo asset closes
    And the icon-button returns to default state

  @ui @positive
  Scenario: Pendo help panel lists all required resource items
    Given the Pendo help panel is open and visible
    When the panel renders
    Then the NowInfinity help centre item is accessible
    And the E-learning and training item is accessible
    And the Onboarding webinars item is accessible
    And the System status item is accessible
    And the Guided walkthroughs item is accessible
    And the Explore & understand platform features (Ideas portal) item is accessible
    And the What's new (Latest product news & upcoming events) item is accessible

  @ui @positive
  Scenario: Account switcher closes when help icon clicked
    Given the account switcher overlay is open
    When the user clicks the help icon-button
    Then the account switcher closes
    And the Pendo help asset activates
    And only one overlay is open

  @ui @positive
  Scenario: App switcher closes when help icon clicked
    Given the app switcher overlay is open
    When the user clicks the help icon-button
    Then the app switcher closes
    And the Pendo help asset activates
    And only one overlay is open

  @ui @positive
  Scenario: Avatar menu closes when help icon clicked
    Given the avatar menu overlay is open
    When the user clicks the help icon-button
    Then the avatar menu closes
    And the Pendo help asset activates
    And only one overlay is open

  @ui @positive
  Scenario: Search overlay closes when help icon clicked
    Given the search overlay is open
    When the user clicks the help icon-button
    Then the search overlay closes
    And the Pendo help asset activates
    And only one overlay is open

  @ui @positive
  Scenario: Pendo asset closes when another header overlay is opened
    Given the help icon-button is in selected state
    And the Pendo asset is visible
    When the user opens another header overlay
    Then the Pendo help asset closes
    And the help icon-button returns to default state

  @mobile @positive
  Scenario: Help listed in mobile/tablet avatar consolidated menu
    Given the user is on a mobile or tablet viewport
    When the user opens the avatar consolidated menu
    Then "Help" is listed as a menu item

  @mobile @positive @smoke
  Scenario: Tapping Help in consolidated menu triggers Pendo asset
    Given the user is on a mobile or tablet viewport
    And the avatar consolidated menu is open
    When the user taps "Help"
    Then the consolidated menu closes
    And the same Pendo-controlled help asset is triggered

  @accessibility @positive
  Scenario: Visible focus ring displayed on keyboard tab to help icon
    Given the help icon-button is in any state
    And the user is navigating via keyboard
    When a keyboard user tabs to the help icon-button
    Then a visible WCAG 2.2 AA focus ring is displayed

  @accessibility @positive
  Scenario: Help icon-button activatable via Enter and Space keys
    Given the help icon-button is focused via keyboard
    When the user presses Enter
    Then the Pendo help asset is triggered
    And the icon-button transitions to selected state
    When the user presses Space on a subsequent focus
    Then the Pendo help asset is triggered

  @accessibility @edge
  Scenario: Focus management follows Pendo asset focus containment when visible
    Given the help icon-button is in any state
    And the user is navigating via keyboard
    When the Pendo help asset becomes visible
    Then focus moves into and is contained within the Pendo asset per its focus containment behaviour

  @negative @edge @gap
  Scenario: Graceful fallback when Pendo SDK not initialised
    Given the Pendo SDK has not been initialised
    When the user clicks the help icon-button
    Then the icon-button does not enter selected state
    And a graceful fallback is presented such as the help centre URL opening in a new tab or a brief notification being shown
    And no unhandled JavaScript error occurs in the console

  @negative @edge
  Scenario: Graceful fallback when Pendo asset target cannot be resolved
    Given the Pendo asset target cannot be resolved
    When the user clicks the help icon-button
    Then the icon-button does not enter selected state
    And a graceful fallback is presented
    And no unhandled JavaScript error occurs in the console

  @analytics @positive
  Scenario: Analytics event fires when help icon-button is clicked
    Given the help icon-button is in its default state
    When the user clicks the help icon-button
    Then an analytics event is recorded for the help icon-button interaction
    And the event reflects the icon-button transitioning to selected state

  @analytics @positive
  Scenario: Analytics event fires when Pendo panel item is selected
    Given the Pendo help panel is open and visible
    When the user selects an item such as System status or What's new
    Then an analytics event is recorded capturing which help panel item was selected
