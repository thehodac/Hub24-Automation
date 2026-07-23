Feature: Avatar Button

  @ui @positive @smoke
  Scenario: Avatar displays user initials in header
    Given the user is authenticated
    And the app header is visible
    When the header renders
    Then an avatar icon-button displaying the user's initials (e.g., "LC" for Linda Cole) is displayed in the top-right area of the header top bar

  @ui @positive @smoke
  Scenario: Clicking avatar opens user menu panel
    Given the avatar button is in its default closed state
    When the user clicks the avatar icon-button
    Then a user menu panel opens anchored to the avatar button

  @ui @positive
  Scenario: Opening avatar menu closes other open header overlays
    Given another header overlay (e.g., app switcher) is currently open
    When the user clicks the avatar icon-button
    Then the user menu panel opens
    And all other open header overlays close simultaneously

  @ui @positive @smoke
  Scenario: User menu displays all items in correct order
    Given the user menu panel is open
    When the panel renders
    Then the user's full name is displayed
    And the user's email address is displayed below the name
    And the current account name is displayed below the email
    And "ASIC service centre" link is displayed below the account name
    And "Product settings" link is displayed below "ASIC service centre"
    And "Portal settings" link is displayed below "Product settings"
    And "Log out" action is displayed last

  @ui @positive @smoke
  Scenario: Product settings navigation from user menu
    Given the user menu is open
    When the user clicks "Product settings"
    Then the user is navigated to the product settings page
    And the menu closes

  @ui @positive @smoke
  Scenario: Portal settings navigation from user menu
    Given the user menu is open
    When the user clicks "Portal settings"
    Then the user is navigated to the portal settings page
    And the menu closes

  @ui @positive @gap
  Scenario: ASIC service centre navigation from user menu
    Given the user menu is open
    When the user clicks "ASIC service centre"
    Then the user is navigated to the ASIC service centre
    And the menu closes
    And this scenario is flagged @gap because "ASIC service centre" has no corresponding PRD requirement entry

  @ui @positive @smoke
  Scenario: Log out terminates session and redirects to login
    Given the user menu is open
    When the user clicks "Log out"
    Then the user's session is terminated
    And the user is redirected to the NowInfinity login page
    And no authenticated session data persists

  @negative @edge
  Scenario: Logged-out session cannot access protected pages via back navigation
    Given the user has logged out via the avatar menu
    When the user presses the browser back button
    Then the user is not shown any previously authenticated page
    And the user remains on or is redirected to the NowInfinity login page

  @ui @positive
  Scenario: Clicking outside the menu closes it
    Given the user menu is open
    When the user clicks anywhere outside the menu panel
    Then the menu closes

  @ui @positive @accessibility
  Scenario: ESC key closes menu and returns focus to trigger
    Given the user menu is open
    When the user presses ESC
    Then the menu closes
    And keyboard focus returns to the avatar icon-button trigger

  @ui @positive
  Scenario: Activating app switcher closes user menu and opens app switcher
    Given the user menu is open
    When the user activates the app switcher
    Then the user menu closes
    And the app switcher overlay opens
    And only one overlay is open at any time

  @ui @positive
  Scenario: Activating account switcher closes user menu and opens account switcher
    Given the user menu is open
    When the user activates the account switcher
    Then the user menu closes
    And the account switcher overlay opens
    And only one overlay is open at any time

  @ui @positive
  Scenario: Activating search closes user menu and opens search
    Given the user menu is open
    When the user activates search
    Then the user menu closes
    And the search overlay opens
    And only one overlay is open at any time

  @ui @positive
  Scenario: Activating help closes user menu and opens help
    Given the user menu is open
    When the user activates help
    Then the user menu closes
    And the help overlay opens
    And only one overlay is open at any time

  @mobile @positive @smoke
  Scenario: Mobile viewport opens full-screen consolidated sl-menu
    Given the user is on a mobile viewport
    When the user taps the avatar icon-button
    Then a full-screen consolidated sl-menu opens
    And the menu displays user name, email, current account name, ASIC service centre, Notifications, Feedback, Help, Product settings, Portal settings, and Log out

  @mobile @positive
  Scenario: Tapping current account row on mobile shows nested account list
    Given the mobile full-screen sl-menu is open
    When the user taps the current account row
    Then a nested account list sub-view is shown
    And the sub-view has a sticky search input
    And the sub-view has a scrollable account list

  @mobile @gap
  Scenario: ASIC service centre visible in mobile consolidated menu
    Given the mobile full-screen sl-menu is open
    When the user views the menu items
    Then "ASIC service centre" is displayed among the consolidated options
    And this scenario is flagged @gap because "ASIC service centre" has no corresponding PRD requirement entry

  @mobile @positive
  Scenario: Tablet viewport opens 320px fixed-width panel
    Given the user is on a tablet viewport
    When the user taps the avatar icon-button
    Then a 320px fixed-width panel opens
    And the panel displays the same consolidated options as the mobile panel

  @mobile @positive
  Scenario: Tapping current account row on tablet reveals nested account list
    Given the tablet 320px panel is open
    When the user taps the current account row
    Then the same nested account list sub-view as mobile is shown

  @edge @negative
  Scenario: Avatar shows fallback placeholder when initials cannot be determined
    Given the user's name data is unavailable
    When the header renders without user name data
    Then the avatar icon-button displays a fallback placeholder such as a generic user icon

  @edge @positive
  Scenario: Menu still opens and shows available data when initials are unavailable
    Given the avatar icon-button displays a fallback placeholder due to missing name data
    When the user clicks the avatar icon-button
    Then the menu opens
    And the menu displays the available profile data

  @accessibility @smoke
  Scenario: Visible focus ring on keyboard tab to avatar button
    Given the header is rendered
    And the user is navigating via keyboard
    When a keyboard user tabs to the avatar icon-button
    Then a visible WCAG 2.2 AA focus ring is displayed on the avatar icon-button

  @accessibility @positive
  Scenario: Menu opens via Enter key when avatar is focused
    Given the avatar icon-button has keyboard focus
    When the user presses Enter
    Then the user menu panel opens

  @accessibility @positive
  Scenario: Menu opens via Space key when avatar is focused
    Given the avatar icon-button has keyboard focus
    When the user presses Space
    Then the user menu panel opens

  @accessibility @positive
  Scenario: Arrow keys navigate menu items
    Given the user menu is open
    When the user presses the arrow keys
    Then keyboard focus moves between the menu items in order

  @accessibility @positive
  Scenario: Enter activates the focused menu item
    Given the user menu is open
    And a menu item has keyboard focus
    When the user presses Enter
    Then the focused menu item is activated

  @accessibility @edge
  Scenario: Focus trapped within open menu panel
    Given the user menu is open
    When the user repeatedly presses Tab
    Then keyboard focus remains within the menu panel
    And focus does not escape to background page content

  @accessibility @edge
  Scenario: Avatar button has accessible name for screen readers
    Given the header is rendered
    When a screen reader user navigates to the avatar icon-button
    Then the screen reader announces an accessible name indicating it opens the user menu

  @analytics
  Scenario: Logout action is tracked in Pendo
    Given Pendo analytics tracking is enabled
    And the user menu is open
    When the user clicks "Log out"
    Then a Pendo logout event is recorded
    And the event includes the user identifier and timestamp

  @analytics
  Scenario: Avatar menu open action is tracked in Pendo
    Given Pendo analytics tracking is enabled
    When the user clicks the avatar icon-button to open the menu
    Then a Pendo avatar-menu-opened event is recorded

  @negative @edge
  Scenario: Rapid repeated clicks on avatar do not break menu state
    Given the avatar button is in its default closed state
    When the user rapidly clicks the avatar icon-button multiple times in quick succession
    Then the menu toggles open and closed without duplicate panels rendering
    And the final state matches the number of clicks (odd = open, even = closed)

  @negative @edge
  Scenario: Menu closes correctly when navigation link fails to load
    Given the user menu is open
    When the user clicks "Portal settings" and the destination page fails to load
    Then the menu still closes
    And an appropriate error state is shown to the user instead of a blank page
