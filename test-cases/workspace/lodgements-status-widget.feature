Feature: Lodgements Status Widget

  @ui @positive @smoke
  Scenario: Widget header and 7 status chips render for user with Corporate Messenger access
    Given a user with Corporate Messenger access loads Workspace
    When the Lodgements Status widget renders
    Then a header "Lodgements Status" displays
    And a row of 7 status-count filter chips displays: Draft, Needs Signature, Signed, Pending, Transmitted, Lodged, Rejected
    And each chip shows an icon and a count

  @ui @positive @negative @smoke
  Scenario: Widget is not displayed for a user without Corporate Messenger access
    Given a user without Corporate Messenger access loads Workspace
    When the page renders
    Then the Lodgements Status widget is not displayed
    And the widget does not occupy a grid slot

  @ui @edge
  Scenario: Widget grid layout reflows correctly when widget is absent for non-entitled user
    Given a user without Corporate Messenger access loads Workspace
    And other Workspace widgets are present
    When the page renders
    Then the remaining widgets reflow to fill the grid
    And no empty placeholder gap is left where the Lodgements Status widget would have been

  @ui @positive @smoke
  Scenario: Default filter state activates Transmitted, Lodged and Rejected only
    Given the widget has loaded
    And the user has not changed any filters
    When the widget renders
    Then Transmitted, Lodged, and Rejected status filters are active
    And Draft, Needs Signature, Signed, and Pending status filters are inactive

  @ui @positive
  Scenario: Default filter state persists on a fresh Workspace load with no saved preferences
    Given a user has never interacted with the widget's status filters before
    When the widget loads for the first time
    Then the table shows only rows with status Transmitted, Lodged, or Rejected
    And the corresponding three chips are visually marked active

  @ui @positive
  Scenario: Clicking an inactive status chip activates it and updates the table
    Given the status filter chip row is visible
    And the Draft chip is inactive
    When the user clicks the Draft chip
    Then the Draft chip toggles to active
    And the table updates to include rows with status Draft in addition to the other active statuses

  @ui @positive
  Scenario: Clicking an active status chip deactivates it and updates the table
    Given the status filter chip row is visible
    And the Rejected chip is active
    When the user clicks the Rejected chip
    Then the Rejected chip toggles to inactive
    And the table updates to exclude rows with status Rejected

  @ui @positive @edge
  Scenario: Multiple status chips can be toggled active simultaneously
    Given the status filter chip row is visible with the default active set
    When the user clicks the Draft, Needs Signature, Signed, and Pending chips in turn
    Then all 7 chips become active
    And the table updates to show rows matching any of the 7 statuses

  @ui @edge @negative
  Scenario: Deactivating all status chips shows no matching rows
    Given the status filter chip row is visible
    When the user clicks every active chip until none remain active
    Then the table shows zero rows
    And no status is marked active

  @ui @positive @accessibility
  Scenario: Hover/focus reveals drag handle, feedback icons, export icon, secondary filter icon and View all link
    Given the widget is in its default state
    When the user hovers or keyboard-focuses the widget
    Then the drag handle becomes visible
    And the thumbs-up and thumbs-down icons become visible
    And the export icon becomes visible
    And the secondary filter icon becomes visible
    And the "View all" link becomes visible

  @ui @negative
  Scenario: Secondary controls are hidden when the widget is neither hovered nor focused
    Given the widget is in its default state
    And the user has not hovered or focused the widget
    When the widget renders
    Then the drag handle, feedback icons, export icon, secondary filter icon, and "View all" link are not visible

  @ui @positive
  Scenario: Secondary filter Date Modified range filters the table and replaces prior selection
    Given the secondary filter dropdown is open
    When the user selects the "Past 7 days" Date Modified range
    Then the table filters to rows modified within the past 7 days
    And any prior Date Modified selection is replaced

  @ui @positive @edge
  Scenario: Each Date Modified range option filters rows to the correct window
    Given the secondary filter dropdown is open
    When the user selects each of Today, Yesterday, Past 7 days, Past 30 days, and Custom in turn
    Then the table filters to rows modified within the selected range for each selection
    And only the most recently selected range remains applied

  @ui @negative @edge
  Scenario: Selecting Anytime does not count as an active filter
    Given the secondary filter dropdown is open
    And a Date Modified range other than Anytime is currently selected
    When the user selects "Anytime"
    Then the table returns to showing rows regardless of Date Modified
    And Anytime does not count as an active filter

  @ui @positive
  Scenario: Selecting one Document Type checkbox filters the table to matching rows
    Given the secondary filter dropdown is open
    When the user selects the "Form 484" Document Type checkbox
    Then the table filters to show only rows with Document Type "Form 484"

  @ui @positive @edge
  Scenario: Selecting multiple Document Type checkboxes filters the table to any matching type
    Given the secondary filter dropdown is open
    When the user selects two or more Document Type checkboxes
    Then the table filters to show rows matching any of the selected document types

  @ui @negative @edge
  Scenario: No Document Type selection shows all document types
    Given the secondary filter dropdown is open
    And no Document Type checkbox is selected
    When the dropdown is applied
    Then the table shows rows of all document types, unfiltered by Document Type

  @ui @positive
  Scenario: Document Type list is searchable
    Given the secondary filter dropdown is open
    And the Document Type list is visible
    When the user types a search term into the Document Type search field
    Then the list filters to show only document types matching the search term

  @ui @positive @edge
  Scenario: Filter icon shows a counter badge for one active filter group
    Given the user has selected a Date Modified range other than Anytime
    And no other secondary filters are active
    When the widget renders
    Then a numeric counter badge showing 1 appears on the filter icon
    And a "Clear filters" link appears

  @ui @positive @edge
  Scenario: Filter icon counter badge caps at 2 when both filter groups are active
    Given the user has selected a Date Modified range other than Anytime
    And the user has selected one or more Document Type checkboxes
    When the widget renders
    Then a numeric counter badge showing 2 appears on the filter icon
    And a "Clear filters" link appears

  @ui @negative
  Scenario: No counter badge or Clear filters link when no secondary filters are active
    Given no secondary filters are active
    When the widget renders
    Then no counter badge appears on the filter icon
    And no "Clear filters" link appears

  @ui @positive
  Scenario: Clear filters resets Date Modified to Anytime and clears Document Type selections
    Given one or more secondary filters are active
    And the "Clear filters" link is visible
    When the user clicks "Clear filters"
    Then Date Modified resets to Anytime
    And Document Type selections clear
    And the counter badge and "Clear filters" link no longer appear

  @ui @positive @smoke
  Scenario: Table rows display Company Name, Document Type, ASIC Status and Date Modified
    Given the table has loaded
    When rows render
    Then each row shows Company Name
    And each row shows Document Type
    And each row shows ASIC Status as a badge with an icon
    And each row shows Date Modified

  @ui @positive
  Scenario: Table sorts by ASIC Status by default with most urgent statuses first
    Given the table has loaded with rows of mixed ASIC Status
    When rows render
    Then rows are sorted by ASIC Status by default
    And the most urgent/actionable statuses appear first

  @ui @positive @edge
  Scenario: Table can be re-sorted by Date Modified as an alternate sort
    Given the table has loaded and is sorted by ASIC Status
    When the user selects the Date Modified sort option
    Then the table re-sorts rows by Date Modified

  @ui @positive @gap
  Scenario: Draft row more-actions menu shows Edit
    Given a row's ASIC Status is Draft
    When the user clicks the row's "more actions" (ellipsis) icon
    Then a menu opens with the action Edit
    And this scenario is flagged @gap pending reconciliation of row action labels between the spec and the live product

  @ui @positive @gap
  Scenario: Needs Signature row more-actions menu shows Mark as sent, Mark as signed, Edit
    Given a row's ASIC Status is Needs Signature
    When the user clicks the row's "more actions" (ellipsis) icon
    Then a menu opens with the actions Mark as sent, Mark as signed, and Edit
    And this scenario is flagged @gap pending reconciliation of row action labels between the spec and the live product

  @ui @positive @gap
  Scenario: Transmitted or Lodged row more-actions menu shows Correct form
    Given a row's ASIC Status is Transmitted or Lodged
    When the user clicks the row's "more actions" (ellipsis) icon
    Then a menu opens with the action "Correct form"
    And this label differs from the "Form Correction" label currently shipped in-product
    And this scenario is flagged @gap pending reconciliation before build

  @ui @positive @gap
  Scenario: Rejected row more-actions menu shows Re-submit
    Given a row's ASIC Status is Rejected
    When the user clicks the row's "more actions" (ellipsis) icon
    Then a menu opens with the action "Re-submit"
    And this label differs from the "Edit" label currently shipped in-product for this action
    And this scenario is flagged @gap pending reconciliation before build

  @ui @negative @edge
  Scenario: No ellipsis icon shown for Signed or Pending rows
    Given a row's ASIC Status is Signed or Pending
    When the row renders
    Then no "more actions" ellipsis icon is shown for that row

  @accessibility @positive
  Scenario: Enter/Space opens the more-actions menu via keyboard
    Given the "more actions" menu is closed
    And the ellipsis icon for a row has keyboard focus
    When the user presses Enter or Space
    Then the menu opens via keyboard alone

  @accessibility @positive
  Scenario: Esc closes the more-actions menu via keyboard
    Given the "more actions" menu is open
    When the user presses Esc
    Then the menu closes via keyboard alone

  @accessibility @positive
  Scenario: Arrow keys navigate the more-actions menu items
    Given the "more actions" menu is open
    When the user presses the Arrow keys
    Then focus moves between menu items via keyboard alone

  @ui @edge @smoke
  Scenario: Empty state displays when zero lodgements match current filters
    Given zero lodgements match the current filters
    When the widget renders
    Then an empty state displays with heading "No active lodgements"
    And body text "You currently have no active lodgements"
    And all status chip counts show 0

  @ui @positive @smoke
  Scenario: View all navigates to the Lodgements page
    Given the widget is visible
    When the user clicks "View all"
    Then the user is navigated to the Lodgements page

  @ui @positive @smoke
  Scenario: Export icon downloads an Excel file of the filtered lodgement data
    Given the widget is visible
    And one or more status and secondary filters are active
    When the user clicks the export icon
    Then an Excel file of the currently filtered lodgement data automatically downloads

  @ui @edge
  Scenario: Export reflects unfiltered data when no filters beyond default are active
    Given the widget is visible in its default filter state
    When the user clicks the export icon
    Then an Excel file downloads containing the data currently shown under the default Transmitted, Lodged, Rejected filter set

  @ui @positive @analytics
  Scenario: Thumbs-up click launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks thumbs-up
    Then the Pendo feedback flow launches
    And no custom feedback modal is displayed

  @ui @positive @analytics
  Scenario: Thumbs-down click launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks thumbs-down
    Then the Pendo feedback flow launches
    And no custom feedback modal is displayed

  @analytics @positive
  Scenario: Status chip toggle fires a Pendo analytics event
    Given the widget is visible
    And Pendo analytics tracking is enabled
    When the user toggles a status filter chip
    Then a Pendo analytics event is captured recording the chip toggle interaction

  @accessibility @positive
  Scenario: More actions button is reachable and operable via keyboard focus, not hover only
    Given a keyboard-only user is navigating the table
    When they tab to a row with available actions
    Then the "more actions" button is reachable via keyboard focus
    And the button is operable via keyboard focus
    And the button is not reachable via hover only

  @accessibility @positive
  Scenario: More actions button exposes an accessible label naming the document
    Given a table row has an available "more actions" button
    When the button receives keyboard focus
    Then it exposes an accessible label "More actions for [document name]"

  @accessibility @positive
  Scenario: Status filter chips are keyboard operable and announce state
    Given a status filter chip has keyboard focus
    When the user presses Enter or Space
    Then the chip toggles active/inactive
    And the chip's active/inactive state is announced to assistive technology

  @mobile @ui @positive
  Scenario: Status chip row remains usable on a mobile viewport
    Given a user with Corporate Messenger access loads Workspace on a mobile viewport
    When the Lodgements Status widget renders
    Then the 7 status-count filter chips are visible and horizontally scrollable or wrapped
    And each chip remains tappable with its icon and count visible

  @mobile @ui @positive
  Scenario: Table rows remain readable and actionable on a mobile viewport
    Given the widget is rendered on a mobile viewport
    When the table renders
    Then Company Name, Document Type, ASIC Status, and Date Modified remain accessible per row
    And the "more actions" control remains reachable by tap for rows with available actions

  @mobile @ui @edge
  Scenario: Secondary filter and export controls remain accessible on mobile without hover
    Given the widget is rendered on a mobile viewport where hover is not available
    When the user taps the widget
    Then the secondary filter icon, export icon, and "View all" link become visible and tappable
    And the drag handle behaviour is adapted appropriately for touch

  @ui @edge @negative
  Scenario: Widget handles rapid successive chip toggles without inconsistent table state
    Given the status filter chip row is visible
    When the user rapidly clicks multiple chips in quick succession
    Then the table settles to reflect exactly the final set of active chips
    And no stale or duplicate rows remain from intermediate states
