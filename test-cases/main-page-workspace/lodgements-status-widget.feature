Feature: Lodgements Status Widget

  @ui @positive @smoke
  Scenario: Pipeline-stage count tiles render across the top of the widget
    Given the user is authenticated and the Workspace page loads
    When the Lodgements Status widget renders
    Then a row of pipeline-stage tiles displays: Draft, Awaiting sign, Signed, Funding, Transmitted, Lodged, and Rejected, each with a label, count, and icon

  @edge
  Scenario: Zero-count stage tiles still render
    Given any stage has a count of zero
    When the widget renders
    Then the tile still displays "0" and is never hidden

  @ui @positive
  Scenario: Clicking a stage tile filters the Recent Lodgements table
    Given the widget is rendered
    When the user clicks the "Rejected" stage tile
    Then the Recent Lodgements table filters to show only lodgements in that pipeline stage
    And the active tile is visually highlighted

  @ui @positive
  Scenario: Clear filter affordance resets the table
    Given a stage filter is active
    When the user activates "Clear filter"
    Then the table returns to showing all recent lodgements unfiltered

  @ui @positive
  Scenario: Recent Lodgements table shows required columns
    Given the Recent Lodgements section renders
    When the table displays
    Then it shows Entity, Lodgement Type, Last Updated, and Status columns

  @functional
  Scenario: Default table sort is by Last Updated descending
    Given the table is in its default unfiltered state
    When the table renders
    Then rows are sorted by Last Updated descending, most recently updated first

  @ui @positive
  Scenario: Status badges render with correct colour coding
    Given a lodgement row renders
    When the Status badge displays
    Then it reflects the pipeline stage with the correct colour: Rejected (red), Transmitted (teal/green), Pending (amber), Draft (grey), Signed (blue), Lodged (green), Awaiting sign (amber)

  @edge
  Scenario: Unrecognised status renders neutral grey badge
    Given a status value is unrecognised
    When the row renders
    Then a neutral grey badge renders with the raw status label

  @functional
  Scenario: Widget includes lodgements across all transaction types
    Given the widget loads
    When lodgements are aggregated
    Then it includes Advice fee consent, Rollover out, Rollover in, Pay anyone, and Agile submissions

  @functional @edge
  Scenario: Advice fee consent statuses map correctly
    Given a lodgement's type is Advice fee consent
    When its status is rendered
    Then it is one of: Denied, Expired, Awaiting submission, Upcoming, Processing, Consent pending, In review, Completed, Cancelled

  @functional
  Scenario: Clicking a lodgement row navigates to the specific record
    Given a lodgement row is displayed
    When the user clicks it
    Then the user is navigated directly to the specific lodgement record for that entity and type

  @negative @edge
  Scenario: Clicking a deleted lodgement shows informational message
    Given the lodgement record no longer exists or has been deleted
    When the user clicks the row
    Then an informational message is shown
    And the widget refreshes to remove the stale row

  @ui @positive
  Scenario: Recent Lodgements section can be collapsed and expanded
    Given the Recent Lodgements section header is visible
    When the user clicks it
    Then the table collapses to show only the section header
    And clicking again expands the table to render all rows

  @ui @edge
  Scenario: Pipeline tiles remain visible when table is collapsed
    Given the Recent Lodgements section is collapsed
    When the widget displays
    Then the pipeline-stage count tiles above remain visible

  @ui @positive
  Scenario: View all lodgements link navigates to full-screen view
    Given the number of recent lodgement rows exceeds the visible table limit
    When the user clicks "View all lodgements"
    Then the user is navigated to a full-screen lodgements list view

  @functional @edge
  Scenario: Full-screen view honours the active stage filter
    Given a stage filter is active
    When the user clicks "View all lodgements"
    Then the full-screen view opens pre-filtered to the active stage

  @edge
  Scenario: No lodgements shows all-zero tiles and empty table state
    Given the firm has no lodgements at any pipeline stage
    When the widget loads
    Then all stage tiles display "0"
    And the table renders "No recent lodgements found."

  @edge
  Scenario: Filtered empty state shows stage-specific message
    Given a stage filter is applied that returns zero matching lodgements
    When the table renders
    Then it shows "No lodgements in [stage name] status."

  @ui @edge
  Scenario: Skeleton loaders show while data is fetching
    Given the widget is fetching data
    When the page is loading
    Then skeleton loaders display in place of the stage tiles and table rows

  @negative
  Scenario: Inline error message shown when data fetch fails
    Given the data fetch fails or times out
    When the failure occurs
    Then an inline error message "Unable to load lodgements data. Please refresh." renders
    And other Workspace widgets are not affected

  @functional
  Scenario: Firm switch refreshes stage counts and table rows
    Given the user switches firms
    When the switch completes
    Then the widget refreshes to display lodgement data for the newly selected firm

  @mobile @ui
  Scenario: Pipeline tiles scroll or wrap on narrow viewport
    Given the widget renders on a narrow viewport
    When the pipeline-stage tiles display
    Then they scroll horizontally or wrap into a two-row grid without overflowing

  @mobile @ui
  Scenario: Recent Lodgements table prioritises key columns on narrow viewport
    Given the Recent Lodgements table renders on a narrow viewport
    When the table displays
    Then it prioritises Entity, Status, and Last Updated columns
    And non-essential columns collapse or are accessible via horizontal scroll

  @accessibility
  Scenario: All interactive elements are keyboard reachable
    Given a keyboard user navigates the widget
    When the user tabs through it
    Then stage tiles, table rows, the collapse toggle, and "View all" link are all reachable via Tab with visible focus indicators

  @accessibility
  Scenario: Status badges convey status via text as well as colour
    Given a status badge is rendered
    When it displays
    Then it conveys status via a text label as well as colour, never by colour alone

  @accessibility
  Scenario: Collapse toggle exposes aria-expanded state
    Given the collapse/expand toggle renders
    When its state changes
    Then it carries aria-expanded="true" or aria-expanded="false" to communicate state to screen readers

  @gap
  Scenario: No direct PRD requirement maps to the Lodgements Status widget
    Given the Lodgements Status widget as designed
    When compared to the PRD requirements table
    Then the closest match, Practice management flags, has TBD acceptance criteria and a narrower scope
    And this is flagged as a design coverage gap pending Product/UX resolution

  @gap
  Scenario: Recent Lodgements section scope (recency window, row cap, sort) is undefined
    Given the Recent Lodgements section is shown
    When reviewing the PRD
    Then no definition exists for the recency window, maximum rows, firm-wide vs assigned-only scope, or sort order
    And this is flagged as a design coverage gap pending Product/UX resolution
