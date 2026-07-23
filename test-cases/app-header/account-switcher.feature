Feature: Account Switcher

  @ui @positive @smoke
  Scenario: Trigger displays current account name with icon
    Given the app header is visible
    When the header renders
    Then the account switcher trigger displays the currently selected account name with the angles-up-down icon

  @ui @positive @edge
  Scenario: Long account name truncates with ellipsis in trigger
    Given the account name exceeds the maximum trigger width
    When the header renders
    Then the account name is truncated with an ellipsis in the trigger

  @ui @positive
  Scenario: Tooltip reveals full account name on trigger hover
    Given the trigger displays a truncated account name
    When the user hovers over the account switcher trigger
    Then a tooltip appears
    And the tooltip reveals the full account name

  @ui @positive @smoke
  Scenario: Clicking trigger opens dropdown anchored to trigger
    Given the account switcher is in its default closed state
    When the user clicks the account switcher trigger
    Then the dropdown opens anchored to the trigger

  @ui @positive
  Scenario: Opening account switcher closes other open header overlays
    Given another header overlay such as notifications is currently open
    When the user clicks the account switcher trigger
    Then the account switcher dropdown opens
    And all other open header overlays close simultaneously

  @ui @positive @edge
  Scenario: Dropdown width remains consistent with trigger width across states
    Given the account switcher dropdown is open
    When the dropdown transitions between its default, search, and filtered states
    Then the dropdown width remains consistent with the trigger width in every state

  @ui @positive
  Scenario: Dropdown with 5 or fewer accounts lists all accounts without a search input
    Given the account switcher dropdown is open
    And the user has 5 or fewer accounts
    When the dropdown renders
    Then all available accounts are listed
    And no search input is displayed

  @ui @positive
  Scenario: Active account is visually highlighted when 5 or fewer accounts exist
    Given the account switcher dropdown is open
    And the user has 5 or fewer accounts
    When the dropdown renders
    Then the active account is visually highlighted in the list

  @ui @positive
  Scenario: Sticky menu label shows total account count for 5 or fewer accounts
    Given the account switcher dropdown is open
    And the user has 5 accounts
    When the dropdown renders
    Then the sticky menu label displays the total count as "Accounts (5)"

  @ui @positive @smoke
  Scenario: Dropdown with more than 5 accounts shows a Filter accounts search input
    Given the account switcher dropdown is open
    And the user has more than 5 accounts
    When the dropdown renders
    Then a "Filter accounts" search input appears above the scrollable list

  @ui @positive
  Scenario: Sticky menu label shows total account count for more than 5 accounts
    Given the account switcher dropdown is open
    And the user has 24 accounts
    When the dropdown renders
    Then the sticky menu label displays the total count as "Accounts (24)"

  @ui @positive @edge
  Scenario: Menu label and search input remain sticky while scrolling the account list
    Given the account switcher dropdown is open
    And the user has more than 5 accounts
    When the user scrolls the account list
    Then the sticky menu label remains fixed in view
    And the "Filter accounts" search input remains fixed in view

  @ui @positive
  Scenario: Search filters the account list in real time as the user types
    Given the account switcher search input is visible
    When the user types 1 or more characters
    Then the list filters in real time using contains, starts-with, and fuzzy matching
    And results update dynamically with each keystroke

  @ui @positive
  Scenario: Matched search text is visually highlighted in filtered results
    Given the account switcher search input is visible
    When the user types a search term that matches part of an account name
    Then the matched text is visually highlighted in the filtered results

  @negative
  Scenario: Empty state is shown when no accounts match the search term
    Given the account switcher search input is visible
    When the user types a search term that matches no accounts
    Then the empty state "No accounts match your search." is displayed

  @ui @positive
  Scenario: Overflowing account list scrolls vertically within the dropdown
    Given the account switcher dropdown is open
    And the account list exceeds the available panel height
    When the list overflows the constrained maximum height
    Then the dropdown scrolls vertically

  @ui @positive @accessibility
  Scenario: Arrow keys navigate the overflowing account list and Enter selects the highlighted account
    Given the account switcher dropdown is open and scrollable
    When the user presses the arrow keys
    Then the list highlight moves between accounts
    When the user presses Enter
    Then the highlighted account is selected

  @ui @positive @smoke
  Scenario: Selecting an account from the dropdown updates the active context and trigger label
    Given the account switcher dropdown is open
    When the user selects an account
    Then the selected account becomes the active context
    And the header trigger updates to display the new account name
    And the dropdown closes

  @ui @positive @smoke
  Scenario: Selecting an account refreshes application data and navigation
    Given the account switcher dropdown is open
    When the user selects a different account
    Then application data refreshes to reflect the new context
    And navigation refreshes to reflect the new context

  @ui @edge
  Scenario: Long account name in dropdown list truncates at a two-line maximum with tooltip
    Given an account name exceeds the maximum display width in the dropdown list
    When the name overflows the available space
    Then the name is truncated with an ellipsis at the two-line maximum
    And a tooltip on hover reveals the full name

  @ui @positive @accessibility
  Scenario: First ESC press exits the search field without closing the dropdown
    Given the account switcher dropdown is open
    And the search input has focus
    When the user presses ESC
    Then the search field loses focus
    And the dropdown remains open

  @ui @positive @accessibility
  Scenario: Second ESC press closes the dropdown
    Given the account switcher dropdown is open
    And the search field has already lost focus from a prior ESC press
    When the user presses ESC again
    Then the dropdown closes

  @ui @positive
  Scenario: Clicking outside the dropdown closes it immediately
    Given the account switcher dropdown is open
    When the user clicks outside the dropdown
    Then the dropdown closes immediately

  @mobile @positive @smoke
  Scenario: Mobile: tapping the avatar icon-button opens a full-screen consolidated menu
    Given the user is on a mobile viewport
    When the user taps the avatar icon-button
    Then a full-screen consolidated sl-menu opens
    And the menu shows the user's name, email, and current account as a tappable row

  @mobile @positive
  Scenario: Mobile: tapping the current account row opens a nested account list sub-view
    Given the mobile full-screen consolidated menu is open
    When the user taps the current account row
    Then a nested account list sub-view appears
    And the sub-view has a sticky search input and a scrollable account list

  @mobile @positive
  Scenario: Tablet: tapping the avatar icon-button opens a 320px fixed-width panel
    Given the user is on a tablet viewport
    When the user taps the avatar icon-button
    Then a 320px fixed-width panel opens
    And the panel shows the same consolidated options as the mobile menu

  @mobile @positive
  Scenario: Tablet: tapping the current account row shows the same nested account list sub-view
    Given the tablet 320px panel is open
    When the user taps the current account row
    Then the same nested account list sub-view appears as on mobile

  @edge @negative
  Scenario: Single-account user sees no switching action and no search input
    Given the authenticated user has only one account
    When the user opens the account switcher
    Then the single account is displayed as the active item
    And no switching action is available
    And no search input is rendered
    And the component renders gracefully

  @accessibility @positive
  Scenario: Visible WCAG 2.2 AA focus ring appears when tabbing to the trigger
    Given the header is rendered
    When a keyboard user tabs to the account switcher trigger
    Then a visible WCAG 2.2 AA focus ring is displayed on the trigger

  @accessibility @positive
  Scenario: Dropdown opens via Enter or Space when the trigger is focused
    Given the account switcher trigger is focused via keyboard
    When the user presses Enter or Space
    Then the dropdown opens

  @negative @gap @edge
  Scenario: Undefined maximum trigger width pixel value creates ambiguous truncation threshold
    Given AC-01 states the trigger name truncates when it exceeds the maximum trigger width
    And the spec does not define the exact pixel or character width threshold
    When QA attempts to verify the truncation breakpoint
    Then the expected truncation width is ambiguous and should be clarified with design before automation

  @analytics @positive
  Scenario: Pendo event fires with account context when a user switches accounts
    Given the account switcher dropdown is open
    When the user selects a different account
    Then a Pendo analytics event is fired recording the account-switch action
    And the event payload includes the source and destination account context
