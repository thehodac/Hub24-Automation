Feature: App Switcher

  @ui @positive @smoke
  Scenario: Tooltip appears on icon-button hover
    Given the app header is rendered
    And the app switcher icon-button is visible
    When the user hovers over the icon-button
    Then a tooltip labelled "Switch apps" appears anchored to the icon-button

  @ui @positive @smoke
  Scenario: Click opens panel with 4px gap and icon enters selected state
    Given the app switcher is in its default (closed) state
    When the user clicks the icon-button
    Then the app switcher panel opens anchored to the trigger with a 4px gap
    And the icon-button enters selected state

  @ui @positive
  Scenario: Opening the app switcher closes other open header overlays
    Given a different header overlay (e.g. account switcher) is currently open
    When the user clicks the app switcher icon-button
    Then the app switcher panel opens
    And all other currently open header overlays close simultaneously

  @ui @positive @smoke
  Scenario: Panel displays all accessible applications with icon and label
    Given the app switcher panel is open
    When the panel renders
    Then all applications accessible to the authenticated user are displayed
    And each application shows its product icon and text label

  @ui @gap
  Scenario: Apps the user is not SSO-authenticated into are still shown for discovery
    Given the app switcher panel is open
    And the user is not SSO-authenticated into one or more listed applications
    When the panel renders
    Then those applications are still displayed in the list for discovery purposes
    And it remains an open question whether this behaviour is final

  @ui @negative
  Scenario: Inaccessible applications are not shown in the panel
    Given the authenticated user does not have access to a given application
    When the app switcher panel renders
    Then that application is not displayed in the list

  @ui @edge
  Scenario: Panel scrolls vertically when the application list overflows panel height
    Given the app switcher panel is open
    And the number of applications exceeds the available vertical panel space
    When the panel renders
    Then the panel scrolls vertically to reveal all items
    And no applications are permanently clipped

  @ui @edge
  Scenario: Panel does not show a scrollbar when the application list exactly fits
    Given the app switcher panel is open
    And the number of applications exactly fills the available vertical panel space
    When the panel renders
    Then no vertical scrollbar is shown
    And all applications remain fully visible

  @ui @positive @smoke @gap
  Scenario: Selecting an application navigates to that application's login page
    Given the app switcher panel is open
    When the user selects an application
    Then the user is navigated to that application's login page
    And no true SSO hand-off occurs because SSO is not yet implemented

  @ui @positive
  Scenario: Panel closes on navigation after an application is selected
    Given the app switcher panel is open
    When the user selects an application
    Then the browser navigates to that application's login page
    And the app switcher panel closes

  @ui @positive
  Scenario: Clicking outside the panel closes it and resets icon-button state
    Given the app switcher panel is open
    When the user clicks anywhere outside the panel
    Then the panel closes
    And the icon-button returns to its default (non-selected) state

  @ui @accessibility @positive
  Scenario: ESC key closes the panel and returns focus to the trigger
    Given the app switcher panel is open
    When the user presses the ESC key
    Then the panel closes
    And keyboard focus returns to the app switcher trigger

  @ui @positive
  Scenario: Opening the account switcher closes the app switcher panel
    Given the app switcher panel is open
    When the user activates the account switcher trigger
    Then the app switcher panel closes
    And the account switcher overlay opens

  @ui @positive
  Scenario: Opening the avatar menu closes the app switcher panel
    Given the app switcher panel is open
    When the user activates the avatar trigger
    Then the app switcher panel closes
    And the avatar overlay opens

  @ui @positive
  Scenario: Opening search closes the app switcher panel
    Given the app switcher panel is open
    When the user activates the search trigger
    Then the app switcher panel closes
    And the search overlay opens

  @ui @positive
  Scenario: Opening help closes the app switcher panel
    Given the app switcher panel is open
    When the user activates the help trigger
    Then the app switcher panel closes
    And the help overlay opens

  @ui @edge
  Scenario: Only one header overlay is open at any time
    Given the app switcher panel is open
    When the user activates any other header overlay trigger
    Then the app switcher panel closes at the same moment the new overlay opens
    And at no point are two header overlays open simultaneously

  @mobile @positive @smoke
  Scenario: Mobile: tapping the hamburger opens a full-screen panel
    Given the user is on a mobile viewport
    When the user taps the hamburger (bars) icon
    Then a full-screen panel opens
    And the panel contains all primary navigation items and a "Switch application" row

  @mobile @positive
  Scenario: Mobile: tapping "Switch application" reveals the application list
    Given the mobile full-screen panel is open
    When the user taps "Switch application"
    Then the accessible application list is revealed
    And each application is shown with its icon and label

  @mobile @positive
  Scenario: Mobile: selecting an application navigates and closes the panel
    Given the mobile application list is displayed
    When the user selects an application
    Then the user is navigated to that application's login page
    And the full-screen panel closes

  @mobile @positive
  Scenario: Tablet: tapping the hamburger opens a 320px fixed-width panel
    Given the user is on a tablet viewport
    When the user taps the hamburger (bars) icon
    Then a 320px fixed-width panel opens
    And the panel contains all primary navigation items and a "Switch application" row

  @mobile @edge
  Scenario: Tablet: application list scrolls when content exceeds panel height
    Given the tablet panel is open
    And the user has tapped "Switch application"
    When the accessible application list content exceeds the panel height
    Then the list scrolls to reveal all remaining items

  @accessibility @smoke
  Scenario: Visible WCAG 2.2 AA focus ring on tabbing to the icon-button
    Given the app header is loaded
    And the user is navigating via keyboard
    When the keyboard user tabs to the app switcher icon-button
    Then a visible WCAG 2.2 AA compliant focus ring is displayed on the icon-button

  @accessibility @positive
  Scenario: App switcher icon-button is activatable via Enter key
    Given the app switcher icon-button has keyboard focus
    When the user presses the Enter key
    Then the app switcher panel opens
    And the icon-button enters selected state

  @accessibility @positive
  Scenario: App switcher icon-button is activatable via Space key
    Given the app switcher icon-button has keyboard focus
    When the user presses the Space key
    Then the app switcher panel opens
    And the icon-button enters selected state

  @accessibility @positive
  Scenario: Arrow keys navigate between application items in the open panel
    Given the app switcher panel is open
    And an application item has keyboard focus
    When the user presses an arrow key
    Then keyboard focus moves to the next or previous application item in the list

  @accessibility @positive
  Scenario: Enter selects the currently focused application item
    Given the app switcher panel is open
    And an application item has keyboard focus
    When the user presses the Enter key
    Then the focused application is selected
    And the user is navigated to that application's login page

  @negative @smoke
  Scenario: Unauthenticated user is redirected to login when opening the app switcher
    Given the user is unauthenticated
    When the user attempts to open the app switcher
    Then the user is redirected to the NowInfinity login page
    And the app switcher panel does not open

  @negative @edge
  Scenario: Expired session redirects to login and prevents the panel from opening
    Given the user's session has expired
    When the user attempts to open the app switcher
    Then the user is redirected to the NowInfinity login page
    And the app switcher panel does not open

  @negative @gap
  Scenario: Product-list fetch failure error state (open question)
    Given the application list is known at session time without a network call
    And it is undecided whether an AC-07-style error state is still required
    When a product-list fetch failure scenario is exercised
    Then the expected error-state behaviour cannot be verified until this open question is resolved
    And this test case is flagged for design clarification

  @ui @gap
  Scenario: "What is [App]?" info link presence (open question)
    Given the app switcher panel is open
    And it is undecided whether a "What is [App]?" info link should be added per product
    When the panel renders
    Then the presence or absence of an info link per application cannot be verified until this open question is resolved
    And this test case is flagged for design clarification

  @analytics @positive
  Scenario: Pendo tracks an app-switch event when an application is selected
    Given the app switcher panel is open
    And Pendo analytics tracking is enabled
    When the user selects an application
    Then a Pendo app-switch event is recorded
    And the event includes the selected application identifier

  @analytics @edge
  Scenario: Pendo app-switch tracking achieves the 100% success-rate target metric
    Given multiple app-switch actions are performed across a test session
    And Pendo analytics tracking is enabled
    When each app-switch action completes
    Then a corresponding Pendo event is recorded for every action with no drops
    And the tracked success rate meets the 100% success-rate target metric
