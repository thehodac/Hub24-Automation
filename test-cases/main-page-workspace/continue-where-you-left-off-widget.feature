Feature: Continue Where You Left Off Widget

  @ui @positive @smoke
  Scenario: In-progress items render grouped by product category
    Given the user is authenticated and the Workspace page loads
    When the Continue Where You Left Off widget renders
    Then in-progress items are grouped by category sections: Trusts, Companies, Funds, and Lodgements

  @ui @edge
  Scenario: Empty category sections are hidden
    Given a category has no in-progress items
    When the widget renders
    Then that category section is hidden and no empty category label is shown

  @ui @positive
  Scenario: Item row displays required fields
    Given items render within a category section
    When a row displays
    Then it shows the category label, entity/document name, status badge, relative timestamp, and assigned user avatar

  @ui @edge
  Scenario: Missing assigned user shows generic avatar placeholder
    Given the assigned user's name is unavailable
    When the item row renders
    Then a generic avatar placeholder is shown
    And no broken image or blank space is rendered

  @functional
  Scenario: Clicking a row navigates to the in-progress record with context
    Given an in-progress item row is displayed
    When the user clicks it
    Then the user is navigated to the specific record with entity name, document type, workflow step, and pre-filled values preserved

  @negative @edge
  Scenario: Clicking a stale item shows informational message
    Given the target record has been completed, cancelled, or deleted by another user
    When the user clicks the row
    Then the user is shown a clear informational message
    And the widget refreshes to remove the stale item

  @functional
  Scenario: Items are sorted by most recently accessed within each category
    Given items render within a category section
    When the section displays
    Then items are sorted by most recently accessed first

  @functional @edge
  Scenario: Categories are ordered by recency of their most recent item
    Given items span multiple categories
    When the widget renders
    Then category sections are ordered by the recency of the most recently accessed item in each section

  @ui @edge
  Scenario: Widget-level empty state shown when no in-progress items exist
    Given the user has no in-progress items across any product category
    When the widget loads
    Then an empty state message "No work in progress. Start a new document or workflow to see it here." renders
    And a "Start a new document" CTA link is provided

  @ui @edge
  Scenario: Skeleton loaders show while items are fetching
    Given the widget is fetching in-progress items
    When the page is loading
    Then skeleton loaders display in place of item rows

  @negative
  Scenario: Inline error message shown when data fetch fails
    Given the data fetch fails or times out
    When the failure occurs
    Then an inline error message "Unable to load your recent work. Please refresh." renders
    And other Workspace widgets are not affected

  @ui @positive
  Scenario: Status badge colours reflect item state
    Given an item has an "In Progress" status
    When the badge renders
    Then it displays in blue with the text "In Progress"
    And a "Pending" status renders in amber

  @edge
  Scenario: Unrecognised status renders neutral grey badge
    Given a status value is unrecognised
    When the item row renders
    Then a neutral grey badge renders with the raw status label

  @functional @edge
  Scenario: Relative timestamps format correctly by recency
    Given an item was last accessed today
    When the timestamp renders
    Then it shows "Today, [H:MM am/pm]"
    And items from the previous day show "Yesterday, [H:MM am/pm]"
    And items older than 2 days show the absolute date

  @functional
  Scenario: Firm switch refreshes in-progress items
    Given the user switches firms via the account selector
    When the switch completes
    Then the widget refreshes to display in-progress items scoped to the newly selected firm

  @functional
  Scenario: Widget reflects updates from other team members within a session
    Given a shared in-progress item is updated by another user during the current session
    When the next refresh cycle occurs
    Then the widget reflects the updated status and timestamp
    And completed items are removed from the widget

  @ui @positive
  Scenario: View all link navigates to full-screen list view
    Given the number of in-progress items exceeds the visible widget height
    When the user clicks "View all"
    Then the user is navigated to a full-screen list view of all in-progress items

  @mobile @ui
  Scenario: Entity name and status remain visible on narrow viewport
    Given the widget renders on a narrow viewport
    When the row displays
    Then entity name, status badge, and timestamp remain visible
    And assigned user avatars may be de-prioritised or moved to a tooltip

  @accessibility
  Scenario: Item rows are focusable with visible focus indicator
    Given a keyboard user navigates the widget
    When the user tabs through item rows
    Then each row is focusable via Tab with a visible focus indicator

  @accessibility
  Scenario: Screen reader announces full row context
    Given a screen reader is active
    When an item row is announced
    Then it includes product category, entity name, status, and timestamp

  @accessibility
  Scenario: Assigned user avatar carries an aria-label
    Given a user avatar is rendered
    When the avatar displays
    Then it carries an aria-label with the assigned user's name

  @gap
  Scenario: No corresponding PRD requirement maps directly to this widget
    Given the Continue Where You Left Off widget as designed
    When compared to the PRD requirements table
    Then no explicit requirement defines what constitutes an in-progress item, recency rules, or per-category item caps
    And this is flagged as a design coverage gap pending Product/UX resolution
