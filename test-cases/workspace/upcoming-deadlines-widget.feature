Feature: Upcoming Deadlines Widget

  @ui @positive @smoke
  Scenario: Widget renders with header and three tabs for user with Corporate Messenger access
    Given a user with Corporate Messenger access loads Workspace
    When the Upcoming Deadlines widget renders
    Then a header "Upcoming Deadlines" displays
    And three tabs are shown: Lodgements, Annual Statements, and Payments

  @ui @positive
  Scenario: Lodgements and Annual Statements tabs hidden for user without Corporate Messenger access
    Given a user WITHOUT Corporate Messenger access loads Workspace
    When the widget renders
    Then the Lodgements tab is hidden from the tab set
    And the Annual Statements tab is hidden from the tab set

  @ui @gap @negative
  Scenario: Payments tab visibility for user without Corporate Messenger access is undefined by spec
    Given a user WITHOUT Corporate Messenger access loads Workspace
    When the widget renders
    Then verify whether the Payments tab is shown or hidden
    And flag that the spec does not state an equivalent permission gate for the Payments tab
    And confirm actual behaviour with the design/product owner before finalizing this assertion

  @ui @positive
  Scenario: Lodgements tab row displays required columns
    Given the Lodgements tab is active
    When rows render
    Then each row shows Company Name, Due Date, Days Remaining, and Status
    And rows are sorted by Days Remaining by default

  @ui @positive
  Scenario: Annual Statements tab row displays required columns
    Given the Annual Statements tab is active
    When rows render
    Then each row shows Company Name, Payment Deadline, Days Remaining, and Status
    And rows are sorted by Days Remaining by default

  @ui @positive
  Scenario: Payments tab row displays required columns and default sort
    Given the Payments tab is active
    When rows render
    Then each row shows Company Name, Payment Type, Amount, Payment Deadline, Days Remaining, and Status
    And rows are sorted by Days Remaining by default

  @ui @positive
  Scenario: Payments tab rows can be sorted by Amount
    Given the Payments tab is active
    When the user selects sort by Amount
    Then rows re-order by Amount
    And the user can switch back to sort by Days Remaining

  @positive @edge
  Scenario: Lodgements row shows Due soon when annual review date is 3+ days past with outstanding debt and no incoming 480/480F messages
    Given a Lodgements-tab row has an annual review date 3 or more days in the past
    And the company has outstanding debt
    And no incoming 480 or 480F messages exist
    When status is computed
    Then the row displays status "Due soon"

  @positive @edge
  Scenario: Lodgements row shows Due within 10 days of deadline
    Given a Lodgements-tab row's Due Date is within 10 days from today
    When status is computed
    Then the row displays status "Due"

  @positive @edge
  Scenario: Lodgements row shows Overdue once deadline has passed
    Given a Lodgements-tab row's Due Date is in the past
    When status is computed
    Then the row displays status "Overdue"

  @negative @edge
  Scenario: Lodgements row does not show Due soon when incoming 480/480F message exists despite outstanding debt
    Given a Lodgements-tab row has an annual review date 3 or more days in the past
    And the company has outstanding debt
    And an incoming 480 or 480F message exists
    When status is computed
    Then the row does not display status "Due soon"

  @gap @edge
  Scenario: Annual Statements Overdue status applies once payment deadline has passed
    Given an Annual Statements-tab row's Payment Deadline is in the past
    When status is computed
    Then the row displays status "Overdue"

  @gap @edge @negative
  Scenario: Annual Statements Due soon and Due thresholds are undefined pending source document reconciliation
    Given an Annual Statements-tab row is approaching its Payment Deadline
    When status is computed
    Then flag that the exact "Due soon" and "Due" thresholds are not deterministic per the spec
    And confirm the reconciled threshold values with the design/product owner before asserting exact boundary days
    And re-test this scenario once AC-07 is finalized

  @positive @edge
  Scenario: Payments tab Lodgement fee (484/205A) shows Due soon when form created within 28 days of change date
    Given a Payments-tab row is a Lodgement fee of type 484 or 205A
    And the form is created
    And the form is within 28 days of the change date
    When status is computed
    Then the row displays status "Due soon"

  @positive @edge
  Scenario: Payments tab Lodgement fee (484/205A) shows Due within 10 days of deadline
    Given a Payments-tab row is a Lodgement fee of type 484 or 205A
    And the Payment Deadline is within 10 days from today
    When status is computed
    Then the row displays status "Due"

  @positive @edge
  Scenario: Payments tab Lodgement fee (484/205A) shows Overdue once deadline has passed
    Given a Payments-tab row is a Lodgement fee of type 484 or 205A
    And the Payment Deadline is in the past
    When status is computed
    Then the row displays status "Overdue"

  @positive @edge
  Scenario: Payments tab Form 388 Financial report shows Due soon within 3 to 4 month window
    Given a Payments-tab row is a Form 388 Financial report
    And the Payment Deadline is within a 3 to 4 month window from today
    When status is computed
    Then the row displays status "Due soon"

  @positive @edge
  Scenario: Payments tab Form 388 Financial report shows Due within 14 days of deadline
    Given a Payments-tab row is a Form 388 Financial report
    And the Payment Deadline is within 14 days from today
    When status is computed
    Then the row displays status "Due"

  @positive @edge
  Scenario: Payments tab Form 388 Financial report shows Overdue once deadline has passed
    Given a Payments-tab row is a Form 388 Financial report
    And the Payment Deadline is in the past
    When status is computed
    Then the row displays status "Overdue"

  @positive @edge
  Scenario: Payments tab pre-authorisation expiry shows Due soon while active and within 15 workdays of expiry
    Given a Payments-tab row is a pre-authorisation expiry
    And the authorisation is active
    And expiry is within 15 workdays from today
    When status is computed
    Then the row displays status "Due soon"

  @positive @edge
  Scenario: Payments tab pre-authorisation expiry shows Due within 3 workdays of expiry
    Given a Payments-tab row is a pre-authorisation expiry
    And expiry is within 3 workdays from today
    When status is computed
    Then the row displays status "Due"

  @positive @edge
  Scenario: Payments tab pre-authorisation expiry shows Overdue once expiry has passed
    Given a Payments-tab row is a pre-authorisation expiry
    And the expiry date is in the past
    When status is computed
    Then the row displays status "Overdue"

  @ui @positive
  Scenario: Hover reveals filter button, feedback icons, export icon, and View all
    Given the widget is in its default state
    When the user hovers over the widget
    Then the filter button becomes visible
    And the thumbs-up and thumbs-down icons become visible
    And the export icon becomes visible
    And "View all" becomes visible where applicable per tab

  @ui @positive @accessibility
  Scenario: Keyboard focus reveals filter button, feedback icons, export icon, and View all
    Given the widget is in its default state
    When the user moves keyboard focus onto the widget
    Then the filter button becomes visible
    And the thumbs-up and thumbs-down icons become visible
    And the export icon becomes visible
    And "View all" becomes visible where applicable per tab

  @ui @positive
  Scenario: Filter button is hidden by default before hover or focus
    Given the widget is in its default state
    And the widget has not been hovered or focused
    When the widget renders
    Then the filter button is not visible

  @ui @positive
  Scenario: Filter menu offers Status checkboxes and Due date range on Lodgements tab
    Given the Lodgements tab is active
    And the filter icon is clicked
    When the filter menu opens
    Then it offers a Status checkbox list with Overdue, Due, and Due soon
    And it offers a date-range field labelled "Due date"
    And the date-range field offers values Anytime, Today, Yesterday, Past 7 days, Past 30 days, and Custom

  @ui @positive
  Scenario: Filter menu offers Status checkboxes and Payment deadline range on Annual Statements tab
    Given the Annual Statements tab is active
    And the filter icon is clicked
    When the filter menu opens
    Then it offers a Status checkbox list with Overdue, Due, and Due soon
    And it offers a date-range field labelled "Payment deadline"
    And the date-range field offers values Anytime, Today, Yesterday, Past 7 days, Past 30 days, and Custom

  @ui @positive
  Scenario: Filter menu offers Status checkboxes, Payment deadline range, and Payment type multi-select on Payments tab
    Given the Payments tab is active
    And the filter icon is clicked
    When the filter menu opens
    Then it offers a Status checkbox list with Overdue, Due, and Due soon
    And it offers a date-range field labelled "Payment deadline"
    And it offers an additional searchable "Payment type" multi-select filter

  @gap @negative @ui
  Scenario: Filter menu caption text does not match this widget's actual field labels
    Given the filter icon is clicked on any tab
    When the filter menu opens
    Then verify the menu caption text
    And flag that the caption "refines the table by Date modified and Document type" does not match the widget's actual fields Due date, Payment deadline, and Payment type
    And confirm the correct caption copy with design before this assertion is finalized

  @ui @positive
  Scenario: Active filters are visually indicated near the filter icon
    Given one or more filters are active
    When the widget renders
    Then an applied-filter indicator displays near the filter icon

  @ui @positive
  Scenario: Clear filters link resets active filters
    Given one or more filters are active
    When the user clicks the "Clear filters" link
    Then all active filters are reset
    And the applied-filter indicator near the filter icon is removed

  @ui @positive @negative
  Scenario: Clear filters link is not available when no filters are active
    Given no filters are active
    When the widget renders
    Then the "Clear filters" link is not shown

  @ui @positive
  Scenario: View all on Lodgements tab navigates to the Lodgements page
    Given the Lodgements tab is active
    When the user clicks "View all"
    Then the user navigates to the corresponding Lodgements page

  @ui @positive
  Scenario: View all on Annual Statements tab navigates to the Annual Statements page
    Given the Annual Statements tab is active
    When the user clicks "View all"
    Then the user navigates to the corresponding Annual Statements page

  @ui @negative
  Scenario: No View all link present on Payments tab
    Given the Payments tab is active
    When the widget renders
    Then no "View all" link is present

  @gap @negative @ui
  Scenario: Row click destination is not defined by the spec for any tab
    Given a row is displayed on any tab
    When the user clicks the row
    Then verify the navigation destination that occurs
    And flag that neither source PDF explicitly illustrates the row click destination
    And confirm the intended destination with design before finalizing this assertion

  @ui @positive @edge
  Scenario: Lodgements tab empty state displays correct heading and body
    Given the Lodgements tab has zero matching rows
    When it renders
    Then an empty state displays heading "No upcoming lodgement deadlines"
    And the body text reads "You currently have no upcoming lodgement deadlines."

  @ui @positive @edge
  Scenario: Annual Statements tab empty state displays correct heading and body
    Given the Annual Statements tab has zero matching rows
    When it renders
    Then an empty state displays heading "No upcoming annual statement deadlines"
    And the body text reads "You currently have no upcoming annual statement deadlines."

  @ui @positive @edge
  Scenario: Payments tab empty state displays correct heading and body
    Given the Payments tab has zero matching rows
    When it renders
    Then an empty state displays heading "No upcoming payment deadlines"
    And the body text reads "You currently have no upcoming payment deadlines."

  @positive @edge
  Scenario: Empty state renders correctly after all filters are applied and no rows match
    Given the user has applied filters on any tab
    And no rows match the applied filters
    When the tab renders
    Then the corresponding empty state heading and body are displayed

  @ui @positive @smoke
  Scenario: Export icon downloads an Excel file of the currently filtered tab data
    Given the widget is visible on any tab
    And one or more filters are applied
    When the user clicks the export icon
    Then an Excel file automatically downloads
    And the downloaded file contains only that tab's currently filtered data

  @negative @edge
  Scenario: Export with zero matching rows still produces a valid Excel file
    Given the widget is visible on a tab with zero matching rows
    When the user clicks the export icon
    Then an Excel file automatically downloads
    And the file contains headers only with no data rows

  @ui @positive @analytics
  Scenario: Thumbs-up click launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks the thumbs-up icon
    Then the Pendo feedback flow launches

  @ui @positive @analytics
  Scenario: Thumbs-down click launches the Pendo feedback flow
    Given the widget is visible
    When the user clicks the thumbs-down icon
    Then the Pendo feedback flow launches

  @analytics @edge
  Scenario: Pendo feedback flow captures the correct widget and tab context
    Given the widget is visible on a specific tab
    When the user clicks thumbs-up or thumbs-down
    Then the Pendo feedback flow launches
    And the feedback event payload identifies the Upcoming Deadlines widget and active tab

  @accessibility @positive
  Scenario: Status badge always pairs a colour indicator with a text label
    Given a status badge is rendered on any tab
    When displayed
    Then the badge shows a colour indicator
    And the badge shows a text label of "Overdue", "Due", or "Due soon"
    And status is never communicated by colour alone, consistent with WCAG 1.4.1

  @accessibility @edge
  Scenario: Status badge remains distinguishable when viewed in grayscale or by a colour-blind user
    Given a status badge is rendered on any tab
    And the page is viewed with a colour-blindness simulation or in grayscale
    When the badge is inspected
    Then the text label "Overdue", "Due", or "Due soon" remains legible and distinguishes the status without relying on colour

  @accessibility
  Scenario: Widget tabs and controls are reachable and operable via keyboard only
    Given the widget is visible
    When the user navigates using only the keyboard
    Then the user can move focus between the Lodgements, Annual Statements, and Payments tabs
    And the user can activate the filter button, export icon, and thumbs-up/thumbs-down icons using the keyboard

  @accessibility
  Scenario: Widget tabs expose correct ARIA roles and states to assistive technology
    Given the widget is visible
    When inspected with an accessibility tree tool
    Then each tab exposes an appropriate ARIA role
    And the active tab exposes an aria-selected state of true
    And inactive tabs expose an aria-selected state of false

  @mobile @ui @positive
  Scenario: Widget renders responsively with tabs accessible on mobile viewport
    Given a user with Corporate Messenger access loads Workspace on a mobile viewport
    When the Upcoming Deadlines widget renders
    Then the header "Upcoming Deadlines" displays
    And the Lodgements, Annual Statements, and Payments tabs are accessible, scrollable, or collapsed into a mobile-appropriate control

  @mobile @positive
  Scenario: Filter menu is usable on mobile viewport
    Given the widget is visible on a mobile viewport
    When the user taps the filter icon
    Then the filter menu opens in a mobile-friendly layout
    And the Status checkboxes and date-range field are usable via touch

  @mobile @positive
  Scenario: Row columns adapt or remain scrollable on narrow mobile widths
    Given the Payments tab is active on a mobile viewport
    When rows render
    Then all required columns remain accessible via horizontal scroll or a responsive stacked layout
    And no column data is clipped or hidden without a way to access it

  @negative @edge
  Scenario: Widget handles data load failure gracefully
    Given the Upcoming Deadlines widget attempts to load data
    And the backing data request fails
    When the widget renders
    Then an error state is displayed instead of a blank or broken widget
    And no unhandled exception is thrown in the console

  @negative @edge
  Scenario: Switching tabs while a filter is applied does not leak filter state across unrelated tabs
    Given a Status filter is applied on the Lodgements tab
    When the user switches to the Payments tab
    Then the Payments tab does not automatically inherit the Lodgements filter selection
    And the Payments tab shows its own independent filter state
