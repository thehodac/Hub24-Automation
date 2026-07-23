Feature: Popular Documents This Month Widget

  @ui @positive @smoke
  Scenario: Widget renders up to 6 ranked document rows
    Given the user is authenticated and the Workspace page loads
    When the Popular Documents This Month widget renders
    Then up to 6 document rows display, each with a category icon, template name, category label, and usage count

  @ui @edge
  Scenario: Fewer than 6 items shows only available rows
    Given fewer than 6 popular documents are available
    When the widget renders
    Then only the available items are shown
    And no empty placeholder rows are rendered

  @functional
  Scenario: List is sorted descending by usage count
    Given the widget has loaded its ranked document list
    When the list renders
    Then documents are sorted in descending order by usage count

  @edge
  Scenario: Tied usage counts are sorted alphabetically
    Given two document types share the same usage count
    When the list renders
    Then they are sorted alphabetically by document name as a tiebreaker

  @edge
  Scenario: All-zero usage counts show empty state
    Given a usage count is zero for all items
    When the widget renders
    Then it displays the empty state message "No popular documents yet this month."

  @functional
  Scenario: Clicking a document row navigates to document creation with type pre-selected
    Given a document item in the list is displayed
    When the user clicks it
    Then the user is navigated to the document creation flow with the document type pre-selected

  @negative @edge
  Scenario: Clicking a deprecated document shows informational message
    Given the document template is no longer available
    When the user clicks the row
    Then an informational message displays rather than navigating to a broken flow

  @functional
  Scenario: Widget is scoped to the current firm
    Given the widget loads
    When usage counts are calculated
    Then they reflect document creation activity within the currently selected firm only

  @functional
  Scenario: Firm switch refreshes the popularity data
    Given the user switches firms via the account selector
    When the switch completes
    Then the widget refreshes to display popularity data scoped to the newly selected firm

  @ui @positive
  Scenario: Category icon colour matches the document's product category
    Given a document row renders
    When the category icon displays
    Then its colour matches the product category of the document

  @edge
  Scenario: Unmapped product category uses neutral fallback icon
    Given a product category is unrecognised or unmapped
    When the row renders
    Then a neutral/default icon colour is applied
    And no missing or broken icon is displayed

  @functional @edge
  Scenario: Usage counts reflect the current calendar month only
    Given the widget loads at any point during a calendar month
    When usage counts render
    Then they reflect document creations from the 1st of the current month to the current date

  @edge
  Scenario: Month rollover resets the widget data
    Given the calendar month rolls over
    When the new month begins
    Then the widget resets to reflect the new month's data
    And previous month counts are no longer shown

  @ui @edge
  Scenario: Skeleton loaders show while document list is fetching
    Given the widget is fetching its document list
    When the page is loading
    Then skeleton loaders display in place of each document row

  @negative
  Scenario: Inline error message shown when data fetch fails
    Given the data fetch fails or times out
    When the failure occurs
    Then an inline error message "Unable to load popular documents. Please refresh." renders
    And other Workspace widgets are not affected

  @negative @functional
  Scenario: Document types outside role-based access are excluded
    Given a document type falls outside the user's role-based access permissions
    When the list renders
    Then that document type is excluded entirely and never shown as a locked or inaccessible item

  @mobile @ui
  Scenario: Document name and category label reflow on narrow viewport
    Given the widget renders at reduced viewport width
    When a row displays
    Then the document name and category label reflow without truncation, or truncate with an accessible tooltip

  @accessibility
  Scenario: Document rows are keyboard focusable
    Given a keyboard user navigates the widget
    When the user tabs through document rows
    Then each row is focusable via Tab key with a visible focus indicator

  @accessibility
  Scenario: Screen reader announces name, category, and usage count
    Given a screen reader is active
    When a document row is announced
    Then it includes document name, category label, and usage count

  @analytics
  Scenario: Pendo event fires on document row click
    Given a user clicks a document row
    When the click is registered
    Then a Pendo event is fired capturing document template name, product category, usage rank position, and user role

  @analytics
  Scenario: Pendo impression event fires on widget load
    Given the widget loads with data
    When the render completes
    Then a Pendo impression event is fired to track widget engagement rates

  @gap
  Scenario: Design delivers a popularity ranking, not the PRD's Favourites requirement
    Given the PRD specifies a user-curated Favourites widget
    When comparing it to the delivered "Popular Documents This Month" design
    Then the design implements an aggregate popularity ranking instead of a personalised bookmarking feature
    And this is flagged as a design coverage gap pending Product/UX resolution
