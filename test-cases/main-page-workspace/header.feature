Feature: Header

  @ui @positive @smoke
  Scenario: Global navigation bar renders all required elements
    Given the user is authenticated and the Workspace page loads
    When the page renders
    Then the global navigation bar shows the NowInfinity logo, search bar, product nav links, notification bell, help icon, account/firm selector, and user avatar

  @negative @edge
  Scenario: Remaining nav elements render if one element fails to load
    Given one navigation element fails to load
    When the page renders
    Then the remaining nav elements still render without layout breakage

  @ui @positive
  Scenario: Personalised greeting displays the user's first name
    Given the authenticated user's session contains a valid first name
    When the header panel loads
    Then a greeting renders as "Hello [First Name]."

  @edge
  Scenario: Greeting falls back gracefully when first name is unavailable
    Given the first name is not available in the user profile
    When the header panel loads
    Then the greeting falls back to "Hello."
    And no blank placeholder or broken markup is rendered

  @ui @positive
  Scenario: Contextual insight message displays when activity data exists
    Given the system has sufficient user activity and workflow history data
    When the header renders
    Then a contextual insight message displays beneath the greeting summarising workload patterns or overdue items

  @edge
  Scenario: New user without activity data sees no empty message container
    Given the user is new or insufficient activity data exists
    When the header renders
    Then the contextual message is omitted or replaced with a generic onboarding prompt
    And no empty message container is visible

  @ui @positive
  Scenario: Quick Actions bar shows 3-5 contextual shortcuts
    Given the system has analysed the user's recent workflow and activity patterns
    When the Quick Actions bar renders
    Then 3 to 5 contextual shortcut action buttons display

  @edge
  Scenario: Default shortcuts shown when user has no workflow history
    Given the user has no workflow history
    When the Quick Actions bar renders
    Then a set of platform-default recommended shortcuts is shown
    And the bar is never empty

  @functional
  Scenario: Clicking a Quick Action launches the workflow with pre-filled context
    Given a relevant client/entity context is determinable from session state
    When the user selects a shortcut
    Then the corresponding workflow launches immediately with required context fields pre-filled

  @functional @edge
  Scenario: Quick Action launches cleanly when context cannot be pre-filled
    Given context cannot be pre-filled
    When the user selects a shortcut
    Then the workflow launches in a clean, unbroken default state

  @ui @positive
  Scenario: Start a new document CTA is visible and functional
    Given the header panel is fully rendered
    When the user views the header
    Then a "+ Start a new document" primary CTA is visible and right-aligned
    And clicking it initiates the new document creation flow

  @ui @positive @smoke
  Scenario: Workload summary stats bar renders three KPI tiles
    Given the user has active workload items across the platform
    When the header loads
    Then three KPI tiles render: Deadlines due soon, In progress, and Pending signatures

  @edge
  Scenario: Zero-count KPI tiles still render
    Given any KPI count is zero
    When the header loads
    Then that tile still renders displaying "0"

  @functional
  Scenario: Clicking a stat tile navigates to the corresponding widget section
    Given the workload summary stats bar is rendered
    When the user clicks the "Pending signatures" tile
    Then the page navigates to the Needs Your Attention widget's Signatures tab

  @ui @positive
  Scenario: Active product nav link is visually highlighted
    Given the user selects a product nav link
    When the navigation completes
    Then the active link is visually highlighted to indicate the current product context

  @functional
  Scenario: Header refreshes with fresh data on return to Workspace
    Given the user returns to the Workspace
    When the header re-renders
    Then it shows fresh, up-to-date workload data and stale cached state is never served

  @negative
  Scenario: Unauthenticated user is redirected to login
    Given an unauthenticated user attempts to access the Workspace
    When the request is made
    Then the user is redirected to the login page
    And no personalised header content is rendered

  @negative @edge
  Scenario: Expired session triggers re-authentication prompt
    Given a session expires mid-session
    When the expiry is detected
    Then the header triggers a re-authentication prompt rather than rendering blank or broken UI elements

  @ui @edge
  Scenario: Skeleton loaders display for stat counts and Quick Actions while loading
    Given stat counts or Quick Actions are still loading
    When the page renders
    Then skeleton loaders display within the respective header zones
    And the greeting and navigation render immediately from cached session data

  @negative
  Scenario: Graceful error state shown when data fetch fails
    Given a data fetch fails with a network timeout or API error
    When the failure occurs
    Then the affected zone renders a graceful error state such as "—" for counts
    And the header layout is not broken

  @mobile @ui
  Scenario: Product navigation collapses to hamburger menu on narrow viewport
    Given the header renders at a viewport below 1024px
    When the page displays
    Then product navigation links collapse into a hamburger/menu icon

  @mobile @ui
  Scenario: Quick Actions scroll or stack responsively on narrow viewport
    Given Quick Action shortcuts exceed available horizontal width
    When the header renders on a narrow viewport
    Then they scroll horizontally or stack responsively without overflowing

  @ui @positive
  Scenario: Search bar shows typeahead suggestions
    Given the user focuses the global search bar
    When the user types 2 or more characters
    Then typeahead suggestions for matching entities and documents render in a dropdown

  @edge
  Scenario: Search with zero results shows empty state message
    Given the user submits a search query
    When the query returns zero results
    Then an empty state message "No results found for '[query]'." displays

  @functional
  Scenario: Firm switcher lists all accessible firms and reloads scoped data
    Given the user has access to multiple firms
    When the user selects a different firm from the account selector dropdown
    Then the Workspace reloads scoped to the newly selected firm
    And header stats, shortcuts, and greeting context refresh accordingly

  @accessibility
  Scenario: All interactive header elements are keyboard reachable
    Given a keyboard-only user navigates the header
    When the user tabs through it
    Then all interactive elements are reachable via Tab key with a visible focus ring

  @accessibility
  Scenario: Header elements carry ARIA labels and landmark regions
    Given screen reader software is active
    When the header renders
    Then all elements carry appropriate ARIA labels, roles, and landmark regions

  @accessibility
  Scenario: Dynamic stat tile updates are announced via aria-live
    Given stat tile counts update dynamically
    When the update occurs
    Then an aria-live region announces the count change to screen readers without disrupting page flow

  @analytics
  Scenario: Pendo events fire on Quick Action and CTA clicks
    Given telemetry instrumentation is active
    When the user clicks a Quick Action shortcut, the CTA, a stat tile, a nav link, or the account switcher
    Then a corresponding Pendo click event is fired

  @gap
  Scenario: Notification panel interaction model is unspecified
    Given the header shows a notification bell icon
    When reviewing the UX specification
    Then no design exists for the notification panel UI, read/unread state, grouping logic, or email preference controls
    And this is flagged as a design coverage gap pending Product/UX resolution

  @gap
  Scenario: Contextual AI insight message has no PRD requirement or data source definition
    Given the header shows a personalised AI-generated contextual message
    When reviewing the PRD
    Then no requirement, data source, inference model, or fallback rule is documented for this behaviour
    And this is flagged as a design coverage gap pending Product/UX resolution
