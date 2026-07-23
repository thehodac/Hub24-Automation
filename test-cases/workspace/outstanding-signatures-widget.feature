Feature: Outstanding Signatures Widget

  @ui @positive @smoke
  Scenario: Widget renders header and table rows in default state
    Given a user loads Workspace
    When the Outstanding Signatures widget renders
    Then a header "Outstanding Signatures" displays
    And a table of rows renders in default, non-hover state

  @ui @positive
  Scenario: Header interaction icons hidden in default state
    Given the widget is in its default (non-hovered, non-focused) state
    When it renders
    Then the drag handle, thumbs-up/thumbs-down icons, export icon, filter icon, and "View all" are not visible
    And only the header title and table are shown

  @ui @positive @smoke
  Scenario: Header interaction icons appear on hover
    Given the widget is in its default state
    When the user hovers over the widget
    Then the drag handle becomes visible
    And the thumbs-up and thumbs-down icons become visible
    And the export icon becomes visible
    And the filter icon becomes visible
    And "View all" becomes visible

  @ui @positive @accessibility
  Scenario: Header interaction icons appear on keyboard focus
    Given the widget is in its default state
    When the user keyboard-focuses the widget
    Then the drag handle, thumbs-up/thumbs-down icons, export icon, filter icon, and "View all" become visible
    And the same elements are revealed as on mouse hover

  @ui @positive @smoke
  Scenario: Table row displays all five required columns
    Given the table has loaded
    When a row renders
    Then it shows Entity Name
    And it shows Document Type
    And it shows Date Sent for e-signing
    And it shows Status
    And it shows Signing Status in the format "X out of X signed"

  @ui @positive
  Scenario: Rows default-sort by Date Sent for e-signing
    Given the table has loaded with multiple rows
    When no user sort has been applied
    Then rows are ordered by Date Sent for e-signing by default

  @ui @positive
  Scenario: Status displays "Due soon" in green at 28+ days from date sent
    Given a row's deadline is 28 or more days from the date sent
    When status is computed
    Then it displays "Due soon"
    And the indicator is coloured green

  @ui @positive @edge
  Scenario: Status displays "Due" in orange when deadline is within 7 days
    Given a row's deadline is within 7 days
    When status is computed
    Then it displays "Due"
    And the indicator is coloured orange

  @ui @negative @edge
  Scenario: Status displays "Overdue" in red once the deadline has passed
    Given a row's deadline has passed
    When status is computed
    Then it displays "Overdue"
    And the indicator is coloured red

  @edge
  Scenario: Status boundary at exactly 7 days resolves to "Due" not "Due soon"
    Given a row's deadline is exactly 7 days from today
    When status is computed
    Then it displays "Due"
    And it does not display "Due soon"

  @edge
  Scenario: Status boundary at exactly 28 days resolves to "Due soon"
    Given a row's deadline is exactly 28 days from the date sent
    When status is computed
    Then it displays "Due soon"
    And it does not display "Due"

  @ui @positive @smoke
  Scenario: Signing Status popover opens on hover and shows signed/pending lists
    Given a row is rendered
    When the user hovers the Signing Status area
    Then a popover opens showing "[n] of [n] signed"
    And a "Signed (n)" list with checkmarked names displays
    And a "Pending (n)" list of remaining names displays

  @ui @positive @accessibility
  Scenario: Signing Status popover opens on keyboard focus, not hover only
    Given a keyboard-only user is navigating the widget
    When they focus the Signing Status area
    Then the signing-details popover opens on focus
    And the popover does not require a pointer hover to appear

  @ui @edge
  Scenario: Signing Status popover shows "No signatures completed" when zero are signed
    Given a row has zero completed signatures
    When the user hovers or focuses the Signing Status area
    Then "Signed (0)" displays
    And the text "No signatures completed" displays
    And the full pending list displays

  @ui @positive
  Scenario: Signing Status popover stays open when pointer moves into the popover
    Given the Signing Status popover is open
    When the user moves the pointer from the Signing Status area into the popover
    Then the popover remains visible

  @ui @negative
  Scenario: Signing Status popover closes when the pointer moves away
    Given the Signing Status popover is open
    When the user moves the pointer away from both the Signing Status area and the popover
    Then the popover closes

  @accessibility @negative
  Scenario: Signing Status popover closes on Esc and on focusing elsewhere
    Given the Signing Status popover is open
    When the user presses Esc
    Then the popover closes
    When the user instead focuses elsewhere on the page
    Then the popover also closes

  @negative
  Scenario: Signing Status popover closes when another row is selected
    Given the Signing Status popover is open for one row
    When the user selects another row
    Then the popover for the original row closes

  @ui @positive @smoke
  Scenario: Filter menu offers Status, Date sent, and Document type controls
    Given the filter icon is clicked
    When the filter menu opens
    Then it offers a Status multi-select with Overdue, Due, and Due soon
    And it offers Date sent with Anytime, Today, Yesterday, Past 7 days, Past 30 days, and Custom
    And it offers a searchable Document type multi-select

  @ui @positive
  Scenario: Filters apply immediately on selection
    Given the filter menu is open
    When the user selects a Status, Date sent, or Document type option
    Then the table updates immediately to reflect the selection
    And no separate "Apply" action is required

  @ui @positive @edge
  Scenario: Applied-filter counter badge displays and caps at 3
    Given one or more filters are active
    When the widget renders
    Then an applied-filter counter badge displays
    And a clear (X) affordance displays
    And the badge count does not exceed 3 even if more filters are active

  @ui @positive
  Scenario: Clear filters resets Date sent to Anytime and clears other selections
    Given one or more filters are active
    When the user clicks "Clear filters"
    Then Date sent resets to Anytime
    And Status selections clear
    And Document type selections clear

  @ui @negative
  Scenario: Filter menu closes on outside click, Esc, or repeat filter-button click
    Given the filter menu is open
    When the user clicks outside the menu
    Then the menu closes
    When the user instead presses Esc
    Then the menu also closes
    When the user instead clicks the filter button again
    Then the menu also closes

  @ui @positive @smoke
  Scenario: Clicking a row navigates to the related document/workflow
    Given a table row is displayed
    When the user clicks anywhere on the row
    Then they navigate directly to the related document/workflow

  @accessibility @positive
  Scenario: Enter/Space on a focused row navigates to the related document/workflow
    Given a keyboard-only user has tabbed to a row
    When they press Enter or Space while the row is focused
    Then they navigate directly to the related document/workflow
    And the outcome matches a mouse click on the row

  @ui @positive @smoke
  Scenario: "View all" navigates to the E-Signing page
    Given the widget is visible
    When the user clicks "View all"
    Then they navigate to the E-Signing page

  @ui @edge @smoke
  Scenario: Empty state displays when zero rows match current filters
    Given zero rows match the current filters
    When the widget renders
    Then an empty state displays with heading "No outstanding signatures"
    And body text "You currently have no documents with outstanding signatures"
    And no CTA button is shown

  @ui @positive
  Scenario: Export icon downloads an Excel file of the currently filtered data
    Given the widget is visible with one or more active filters
    When the user clicks the export icon
    Then an Excel file automatically downloads
    And the downloaded data reflects only the currently filtered rows

  @analytics @positive
  Scenario: Thumbs-up launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks thumbs-up
    Then the Pendo feedback flow launches

  @analytics @positive
  Scenario: Thumbs-down launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks thumbs-down
    Then the Pendo feedback flow launches

  @mobile @ui @positive
  Scenario: Widget remains usable and interactive elements reachable on mobile viewport
    Given the Outstanding Signatures widget is displayed on a mobile viewport
    When the widget renders
    Then the header "Outstanding Signatures" and table rows are visible
    And row tap navigates to the related document/workflow the same as desktop click

  @mobile @ui @edge
  Scenario: Filter and export icons remain accessible on touch devices without hover
    Given the widget is displayed on a mobile/touch viewport with no hover capability
    When the user taps the widget
    Then the filter icon, export icon, and "View all" become visible and tappable
    And the icons are not permanently hidden due to the absence of a hover state

  @accessibility
  Scenario: Signing Status popover content is announced to assistive technology
    Given a screen reader user focuses the Signing Status area of a row
    When the popover opens
    Then the "[n] of [n] signed" summary, "Signed" list, and "Pending" list are exposed to assistive technology
    And focus is not silently trapped inside the popover

  @negative @edge
  Scenario: Filter menu with no matching Document type search results shows no options
    Given the filter menu's Document type search field is open
    When the user types a query that matches no document types
    Then the Document type list shows no selectable options
    And existing Status and Date sent selections remain unaffected

  @gap
  Scenario: Corporate Messenger entitlement gate for the widget is unconfirmed
    Given the Lodgements Status widget is gated behind a Corporate Messenger (or other) entitlement
    When the Outstanding Signatures widget's Deliverable Breakdown is reviewed
    Then it flags an open question on whether this widget requires the same entitlement gate
    And this design coverage gap requires PO/design confirmation before implementation

  @gap
  Scenario: Row click-through destination page is unconfirmed
    Given AC-10 specifies that clicking a row navigates to "the related document/workflow"
    When the Deliverable Breakdown for this widget is reviewed
    Then the exact destination page for the click-through is noted as pending design confirmation
    And this design coverage gap requires resolution before the navigation behaviour can be fully verified
