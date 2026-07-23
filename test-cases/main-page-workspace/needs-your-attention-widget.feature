Feature: Needs Your Attention Widget

  @ui @positive @smoke
  Scenario: Summary stat cards render with correct counts
    Given the user is authenticated and the Workspace page loads
    When the Needs Your Attention widget renders
    Then three summary stat cards are displayed: Overdue deadlines (red), Awaiting signature (amber), Rejected lodgements (red/pink)
    And each card shows its correct count

  @ui @edge
  Scenario: Zero-count stat cards still render
    Given the user has no overdue deadlines, no awaiting signatures, and no rejected lodgements
    When the widget renders
    Then each stat card still displays "0"
    And no stat card is hidden

  @ui @positive
  Scenario: Deadlines tab is active by default
    Given the widget first renders
    When the user views the widget
    Then the Deadlines tab is active and selected by default
    And the active tab is visually distinguished

  @ui @positive
  Scenario: Switching to Signatures tab filters the table
    Given the widget is rendered
    When the user selects the Signatures tab
    Then the table content filters to show only signature-pending items

  @ui @positive
  Scenario: Switching to Lodgements tab filters the table
    Given the widget is rendered
    When the user selects the Lodgements tab
    Then the table content filters to show only rejected or pending lodgement items

  @ui @positive
  Scenario: Deadlines table displays required columns and status badges
    Given the Deadlines tab is active and data is loaded
    When the table renders
    Then it displays Entity, Deadline Type, Due Date, Days Remaining, and Status columns
    And an overdue item shows a negative Days Remaining and an "Overdue" badge in dark red

  @ui @positive
  Scenario: Due today item shows correct status badge
    Given an item is due today
    When the Deadlines table renders
    Then Days Remaining shows "Today"
    And the Status badge renders as "Due today" in blue

  @ui @functional
  Scenario: Clicking a Deadlines row navigates with full context
    Given the Deadlines tab is active
    When the user clicks on a row
    Then the user is navigated to the relevant client entity file or deadline/task record
    And entity name, deadline type, and due date context is preserved

  @negative @edge
  Scenario: Clicking a row for a resolved deadline shows informational message
    Given a deadline row is displayed
    And the target record has since been completed elsewhere
    When the user clicks the row
    Then an informational message is shown
    And the widget refreshes to remove the resolved item

  @ui @edge
  Scenario: Empty state renders per tab with zero results
    Given the active tab has no items requiring attention
    When the tab is viewed
    Then an empty state message "No items require your attention right now." renders in the table area
    And no broken table structure or blank rows are rendered

  @ui @edge
  Scenario: Widget-level empty state renders when all counts are zero
    Given all three summary stat cards show 0
    When the widget renders
    Then a widget-level empty state message is displayed confirming all items are clear

  @ui @edge
  Scenario: Skeleton loaders show while data is fetching
    Given the widget is fetching data asynchronously
    When the page is loading
    Then skeleton loaders are shown in place of the stat cards and table rows

  @negative
  Scenario: Inline error message shown when data fetch fails
    Given the widget data fetch exceeds 10 seconds or fails
    When the timeout or failure occurs
    Then an inline error message "Unable to load attention items. Please refresh." renders
    And other widgets on the Workspace page are not affected

  @ui @positive
  Scenario: Stat card click activates corresponding tab
    Given items exist across multiple tabs
    When the user clicks a stat card
    Then the corresponding tab is immediately activated
    And the table scrolls into view

  @functional @edge
  Scenario: Table default sort is by urgency
    Given the Deadlines table renders
    When no column sort has been applied
    Then rows are sorted with Overdue items first, then Due today, then Due soon, then Upcoming

  @ui @positive
  Scenario: Column header sort toggles ascending and descending
    Given the Deadlines table is rendered
    When the user clicks a column header
    Then the table re-sorts by that column ascending
    And clicking again reverses the sort to descending
    And a sort indicator icon is visible on the active column

  @functional
  Scenario: Widget data refreshes on page reload
    Given the widget data is stale
    When the user refreshes the Workspace page
    Then the widget fetches fresh data
    And all stat card counts and table rows update

  @mobile @ui
  Scenario: Table columns reflow on narrow viewport
    Given the widget renders on a viewport below 1024px
    When the table displays
    Then columns reflow to prioritise Entity, Status, and Due Date
    And non-critical columns are hidden or accessible via horizontal scroll

  @mobile @ui
  Scenario: Stat cards stack vertically on narrow viewport
    Given the widget renders on a viewport below 1024px
    When the summary stat cards render at reduced width
    Then they stack vertically or reduce in size without truncating count values

  @accessibility
  Scenario: Keyboard focus order moves logically through the widget
    Given a keyboard user is navigating the widget
    When the user tabs through it
    Then focus moves through stat cards, tab controls, and table rows in logical order

  @accessibility
  Scenario: Status badges are not communicated by colour alone
    Given a status badge is rendered
    When it displays
    Then the text label (e.g. "Overdue") is always present for screen reader compatibility

  @accessibility
  Scenario: Sortable column headers expose aria-sort
    Given the table contains sortable columns
    When a column header renders
    Then it carries an aria-sort attribute of "ascending", "descending", or "none"

  @gap
  Scenario: Email notification channel for attention items is unspecified
    Given the PRD requires timely alerts in-app and email
    When reviewing the design for the Needs Your Attention widget
    Then no UX specification exists for email notification templates, preferences, or frequency controls
    And this is flagged as a design coverage gap pending Product/UX resolution

  @gap
  Scenario: Overlap between Lodgements tab and Lodgements Status widget is undefined
    Given this widget includes a Lodgements tab
    And a separate dedicated Lodgements Status widget also exists
    When comparing scope definitions
    Then no PRD guidance differentiates content or status coverage between the two surfaces
    And this is flagged as a design coverage gap pending Product/UX resolution
