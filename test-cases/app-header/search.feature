Feature: Search

  @ui @positive @smoke
  Scenario: First-time user sees default discovery content on focus
    Given a user with no prior search history opens global search for the first time
    When the user focuses the search input without entering a query
    Then the dropdown opens showing default discovery content
    And the default content includes recommended searches and suggested actions/workflows
    And no results are pre-filtered

  @ui @positive
  Scenario: Default discovery shown instead of Recent when no history exists
    Given a user has no recent searches and no recent results
    When the user focuses the search input
    Then default discovery suggestions are shown
    And no "Recent" section is displayed

  @ui @positive @smoke
  Scenario: Returning user sees recent searches and recent results on focus
    Given a returning user has previously entered search queries and opened search results
    When the user focuses the search input with no query entered
    Then the dropdown displays up to 4 recent searches
    And the dropdown displays up to 4 recent results
    And the most recent search term is listed first

  @ui @edge
  Scenario: Recent content dropdown scrolls when combined content overflows
    Given a returning user has 4 recent searches and 4 recent results populated
    When the user focuses the search input and the combined content exceeds the dropdown's visible height
    Then scrolling is enabled so all recent content remains reachable

  @ui @edge
  Scenario: Fewer than 4 recent searches/results still render correctly
    Given a returning user has only 1 recent search and 2 recent results saved
    When the user focuses the search input with no query entered
    Then the dropdown displays the 1 recent search and 2 recent results available
    And no placeholder or error is shown for the missing slots

  @ui @positive
  Scenario: No pre-filtering applied to dropdown content by date range
    Given the search input is focused and no query has been entered
    When the dropdown content is evaluated for applied filters
    Then no pre-filtering by date range is applied to the displayed content

  @ui @positive
  Scenario: No pre-filtering applied to dropdown content by status or workflow state
    Given the search input is focused and no query has been entered
    When the dropdown content is evaluated for applied filters
    Then no pre-filtering by status is applied
    And no pre-filtering by workflow state or any system-level filter is applied
    And filtering is only introduced on the full search results page

  @ui @positive @smoke
  Scenario: Search input expands to minimum width and hides logo on activation
    Given a user is on a desktop breakpoint with the global search input inactive
    When the user activates the global search input
    Then the input expands to a minimum width of 540px
    And the brand logo is hidden

  @ui @positive @edge
  Scenario: Search input grows up to maximum width as viewport widens
    Given a user has activated global search on a desktop breakpoint
    When the viewport width increases
    Then the search input continues to grow up to a maximum width of 860px
    And growth is proportional to the available viewport width

  @ui @edge
  Scenario: Search input growth stops at LG breakpoint with logo hidden
    Given a user has activated global search and the viewport reaches the LG breakpoint of 1440px
    When the viewport width increases beyond 1440px
    Then the search input stops growing beyond its maximum width
    And the brand logo remains hidden while search is active

  @ui @positive
  Scenario: No prior context filters applied when entering a new query
    Given a user enters or edits a search query
    When the query is submitted
    Then results are not pre-filtered by any prior context

  @ui @edge
  Scenario: Large dataset requires 3 characters before returning matches
    Given the searchable dataset for the active query scope contains more than 50 possible results
    When the user types 2 characters into the search input
    Then the dropdown does not yet return matches
    When the user types a 3rd character
    Then the dropdown begins returning matches

  @ui @positive @edge
  Scenario: Small dataset allows filtering after 1 character
    Given the searchable dataset for the active query scope contains 50 or fewer possible results
    When the user types 1 character into the search input
    Then the dropdown may begin filtering and returning matches

  @ui @positive @smoke
  Scenario: Dropdown results update dynamically on each keystroke
    Given the user is actively typing in the search input
    When each keystroke updates the query text
    Then the dropdown results update dynamically to reflect the latest query text

  @ui @positive
  Scenario: Search supports contains, starts-with, and fuzzy matching
    Given a submitted query partially matches an entity name using contains, starts-with, or fuzzy matching rules
    When the query is evaluated against the searchable dataset
    Then matching results are returned using the supported matching method configured for that data domain

  @ui @negative
  Scenario: Typo-tolerant fuzzy match still surfaces close results
    Given a user enters a query containing a minor typo of a known entity name
    When the query is evaluated using fuzzy matching
    Then the closely matching entity is still surfaced in the results

  @ui @positive @smoke
  Scenario: Find intent prioritises matching entities for entity name query
    Given a submitted query matches a known company name
    When the results are ranked
    Then the query is classified with "Find" intent
    And matching entities are prioritised first
    And key entity metadata is surfaced
    And related documents are surfaced beneath the entities

  @ui @positive
  Scenario: Find intent triggered by ABN/ACN identifier
    Given a submitted query is a known ABN or ACN identifier
    When the results are ranked
    Then the query is classified with "Find" intent
    And the matching entity is prioritised first
    And key entity metadata is surfaced

  @ui @positive @smoke
  Scenario: Do intent prioritises workflows for action-oriented query
    Given a submitted query includes action-oriented language such as "lodge"
    When the results are ranked
    Then the query is classified with "Do" intent
    And matching workflows/actions are prioritised first
    And related templates, documents, and guidance are surfaced
    And relevant create actions are made available
    And relevant entities are surfaced

  @ui @positive
  Scenario: Do intent triggered by checklist/reminder keywords
    Given a submitted query includes the word "checklist" or "reminder"
    When the results are ranked
    Then the query is classified with "Do" intent
    And matching workflows/actions are prioritised first

  @ui @positive @smoke
  Scenario: Mixed/Exploratory intent balances result groups for ambiguous query
    Given a submitted query is broad or ambiguous such as "annual statement"
    When the results are ranked
    Then the query is classified with "Mixed/Exploratory" intent
    And the dropdown presents a balanced spread across relevant result groups

  @ui @edge
  Scenario: Exploratory query for a generic entity type balances groups
    Given a submitted query is the generic term "trust" with no further qualifier
    When the results are ranked
    Then the dropdown presents a balanced spread across relevant result groups rather than a single dominant group

  @ui @positive
  Scenario: Results within a group ranked by weighted relevance, recency, frequency, context
    Given multiple results exist within the same result-type group for a submitted query
    When the results are ordered
    Then they are ranked by a weighted combination of text-match relevance, recency, frequency, and user context where available

  @ui @edge
  Scenario: Higher text-match relevance outranks more recent but weaker match
    Given two results exist in the same group where one has a stronger text match and the other is more recently accessed
    When the results are ordered within the group
    Then text-match relevance is applied as the primary ranking factor ahead of recency

  @ui @positive @smoke
  Scenario: Results grouped by type with counts across multiple data domains
    Given results are returned across more than one data domain including Documents, Companies, and Trusts
    When the dropdown renders
    Then results are grouped by type
    And each group displays a count where available
    And each group is ranked internally by relevance

  @ui @edge
  Scenario: Each result-type group caps visible items at approximately 10
    Given a result-type group for a submitted query contains more than 10 matching items
    When the dropdown renders that group
    Then up to approximately 10 items are visible before requiring the full results page

  @ui @positive
  Scenario: Results grouped across Corporate Messenger, Funds, Lodgements, Super Comply, Individuals
    Given results are returned across the Corporate Messenger, Funds, Lodgements, Super Comply, and Individuals domains
    When the dropdown renders
    Then each domain is represented as its own grouped section with a count where available

  @ui @positive
  Scenario: Result item title wraps to 2 lines then truncates
    Given a result item is rendered with a long title
    When the title exceeds 2 lines of available space
    Then the title wraps up to 2 lines and then truncates with an ellipsis

  @ui @edge
  Scenario: Result item secondary metadata truncates on single line without wrapping
    Given a result item is rendered with long secondary metadata text
    When the metadata exceeds the width of a single line
    Then the metadata is limited to 1 line and truncates with an ellipsis without wrapping

  @ui @positive
  Scenario: Status badges/tags on result items are never truncated
    Given a result item is rendered with a status badge or tag
    When the item is displayed in the dropdown
    Then the status badge or tag text is never truncated
    And result type, status, and destination behaviour are visually distinguishable from one another

  @ui @positive @smoke
  Scenario: Matching query text is highlighted within result title and metadata
    Given a result item matches the active query
    When the item is displayed in the dropdown
    Then the matching text within the title and/or metadata is visually highlighted

  @ui @edge
  Scenario: Highlighting applies correctly for multi-word partial matches
    Given a result item matches only part of a multi-word active query
    When the item is displayed in the dropdown
    Then only the matching text segments are visually highlighted, not the full title or metadata

  @ui @positive @smoke
  Scenario: See all results action displayed when more matches exist than visible
    Given more matching results exist than are visible within the dropdown
    When the dropdown renders
    Then a "See all results for '[query]'" action is displayed at the bottom of the dropdown

  @ui @positive @smoke
  Scenario: Selecting See all results navigates to full results page with query applied
    Given the user selects "See all results for '[query]'"
    When the selection is made
    Then the user is navigated to the full search results page with the current query passed through and applied

  @ui @positive @smoke
  Scenario: Top-ranked result is auto-focused by default
    Given the user has entered a search query and results are displayed
    When the results appear in the dropdown
    Then the top-ranked result is auto-focused/highlighted by default

  @ui @positive
  Scenario: Enter key opens the currently highlighted result
    Given the user has entered a search query and a result is highlighted
    When the user presses Enter
    Then the highlighted result is opened

  @ui @positive
  Scenario: Enter with no result highlighted submits query to full results page
    Given the user has entered a search query and no result is highlighted
    When the user presses Enter
    Then the current query is submitted and the user is navigated to the full search results page

  @ui @positive @accessibility
  Scenario: Arrow keys move focus sequentially through dropdown results
    Given the search dropdown is open with results or suggestions visible
    When the user presses the Down arrow key repeatedly
    Then keyboard focus moves sequentially forward through the visible results
    When the user presses the Up arrow key
    Then keyboard focus moves sequentially backward through the visible results

  @ui @positive @accessibility
  Scenario: ESC key closes the dropdown and exits search
    Given the search dropdown is open with results or suggestions visible
    When the user presses the ESC key
    Then search exits and the dropdown closes

  @ui @positive @smoke
  Scenario: Clear control resets input and adds cleared term to recent searches
    Given the user has an active query in the search input
    When the user selects the clear ("x") control
    Then the search term is cleared
    And the input resets
    And the cleared term is added to recent searches

  @ui @positive
  Scenario: Selecting a suggested action navigates to its workflow start point
    Given the default dropdown displays a suggested action/workflow
    When the user selects the suggested action
    Then the user is navigated to the relevant workflow start point/create flow

  @ui @positive
  Scenario: Selecting a recommended search navigates to full results page with term applied
    Given the default dropdown displays a recommended search
    When the user selects the recommended search
    Then the user is navigated to the full results page with the recommended term applied

  @ui @negative @smoke
  Scenario: Zero matches shows No search results state with clear-and-retry option
    Given a submitted query returns zero matches across all data domains
    When the search request completes with no matches
    Then a "No search results" state is shown
    And the message "No results match your search." is displayed
    And an option to "Clear '[query]' and search again." is displayed
    And relevant contextual create actions are shown where supported

  @ui @negative @edge
  Scenario: No-results state shows for a query with only special characters
    Given a user submits a query consisting solely of special characters with no matching entities or documents
    When the search request completes with no matches
    Then the "No search results" state is shown with the message "No results match your search."

  @ui @edge @negative
  Scenario: No premature no-results flash while request is in flight
    Given a search request is in progress and has not yet completed
    When the dropdown is evaluated for what to render
    Then the empty/no-results state must not be shown until the request completes

  @ui @gap @edge
  Scenario: Loading/pending state while search request is in flight
    Given a user has submitted a query and the search request is in flight
    When the request has not yet completed
    Then a loading/pending indicator is shown in place of results or the no-results state
    # @gap: neither PRD nor UX Spec defines the loading/pending state design for an in-flight search request

  @ui @gap @negative @edge
  Scenario: Network timeout or offline during search shows recoverable error state
    Given a user submits a search query while the network connection times out or the device goes offline
    When the search request fails to complete
    Then an appropriate error/offline state is shown and the user can retry once connectivity is restored
    # @gap: neither PRD nor UX Spec defines behaviour on network timeout or offline recovery

  @ui @mobile @positive @smoke
  Scenario: Tapping search icon expands overlay to full header width on mobile
    Given a user is on a mobile breakpoint between 320px and 575px
    When the user taps the search icon
    Then the search input activates
    And the input expands to span the full width of the header bar
    And the search overlay covers other header elements

  @ui @mobile @positive
  Scenario: Tapping search icon expands overlay to full header width on tablet
    Given a user is on a tablet breakpoint between 576px and 989px
    When the user taps the search icon
    Then the search input activates
    And the input expands to span the full width of the header bar, overlaying other header elements

  @ui @mobile @positive
  Scenario: Tapping outside area closes mobile/tablet search overlay
    Given the mobile/tablet search overlay is active
    When the user taps the outside area of the overlay
    Then the search overlay closes and the user exits search

  @ui @mobile @positive @smoke
  Scenario: Left arrow icon-button closes mobile/tablet search overlay
    Given the mobile/tablet search overlay is active
    When the user taps the left arrow icon-button
    Then the search overlay closes and the user exits search

  @ui @mobile @positive
  Scenario: Mobile result cards prioritise title, type, status, and destination clarity
    Given search result cards are rendered at a mobile breakpoint
    When a card is displayed
    Then the card prioritises title, result type, status, and destination clarity consistent with the desktop truncation rules

  @ui @mobile @edge
  Scenario: Mobile result card title truncation matches desktop 2-line rule
    Given a search result card is rendered at a mobile breakpoint with a long title
    When the title exceeds 2 lines of available space
    Then the title wraps up to 2 lines then truncates with an ellipsis, consistent with the desktop behaviour

  @ui @positive @smoke
  Scenario: Filter tab on full results page displays a result count for the type
    Given a user reaches the full search results page with filters available
    When the user applies a filter tab for a given result type
    Then the page displays a result count for that type such as "39 Companies found"

  @ui @positive
  Scenario: Full results page supports sort by relevance, date, and name
    Given a user reaches the full search results page with sorting controls available
    When the user opens the sort control
    Then the user can sort by relevance
    And the user can sort by date
    And the user can sort by name

  @ui @positive @edge
  Scenario: Pagination or load-more provided when results exceed one page
    Given more results exist than fit on one page of the full search results page
    When the results page renders
    Then pagination or a load-more control is provided to access the remaining results

  @ui @positive @smoke
  Scenario: Global search entry point available consistently across user roles
    Given any authenticated NowInfinity user role opens the application
    When the header renders
    Then the global search entry point is available consistently regardless of role, subject to existing entity/document access permissions

  @ui @negative @edge
  Scenario: Search results respect entity/document access permissions per role
    Given a user role with restricted access to certain entities or documents submits a query matching a restricted item
    When the search results are returned
    Then the restricted entity or document is not surfaced to that user, consistent with existing access permissions

  @ui @positive
  Scenario: Submitting a query updates the recent searches list
    Given a user's recent-search history currently has fewer than 4 entries
    When the user submits a new query
    Then the recent searches list reflects the newly submitted query, up to a maximum of 4 entries

  @ui @edge
  Scenario: Recent searches list caps at 4 and evicts oldest entry on overflow
    Given a user's recent-search history already contains 4 entries
    When the user submits a 5th distinct query
    Then the recent searches list still shows a maximum of 4 entries with the oldest entry evicted and the new query added

  @ui @positive
  Scenario: Clearing a query adds it to recent searches per AC-19 and AC-28
    Given a user has an active query in the search input
    When the user selects the clear ("x") control
    Then the recent searches list reflects the addition of the cleared query, up to the maximum of 4 entries

  @ui @accessibility @positive @smoke
  Scenario: Focus enters search input in logical, visible order
    Given a keyboard-only user tabs through the application header
    When focus reaches the global search input
    Then focus is visibly indicated per WCAG 2.2 focus-visible requirements and the focus order is logical

  @ui @accessibility @positive
  Scenario: Focus moves logically through dropdown results and See all results control
    Given a keyboard-only or assistive-technology user has the search dropdown open with results visible
    When the user moves focus through the results using the keyboard
    Then focus order proceeds logically through each visible result
    And focus order reaches the "See all results" action last
    And focus is visibly indicated at every step

  @ui @accessibility @edge
  Scenario: Focus-visible and focus-order requirements hold at every breakpoint
    Given a keyboard-only or assistive-technology user interacts with global search
    When the breakpoint changes between desktop, tablet, and mobile
    Then focus order and focus-visible indication remain logical and visible per WCAG 2.2 at every breakpoint

  @ui @gap @negative
  Scenario: Cross-product federated search scope is undefined for products/accounts/help
    Given a user submits a query intended to span products, accounts, and help as described in the PRD
    When the search request is evaluated
    Then no design exists in the UX Spec/Figma for federated cross-Class-suite results such as Class Super, Class Trust, or Class Portfolio, so results remain scoped to NowInfinity data domains only
    # @gap: PRD says search should span "products, accounts, and help" but UX Spec/Figma are scoped entirely to NowInfinity data domains

  @ui @gap @negative
  Scenario: Help/documentation content is absent as a searchable result type
    Given a user submits a query that matches help or documentation content referenced in the PRD
    When the search request is evaluated against the supported data domains
    Then no help/documentation result type is returned because it does not appear anywhere in the UX spec's supported domains
    # @gap: PRD includes "help" as a search target but no help/documentation result type appears in the UX spec

  @analytics @positive
  Scenario: Search query submission is tracked for analytics
    Given a user submits a search query
    When the query is submitted
    Then a search-submitted analytics event is captured including the query text, intent classification, and result count

  @analytics @positive
  Scenario: Result selection from dropdown is tracked with position and type
    Given a user selects a result item from the search dropdown
    When the selection is made
    Then a result-selected analytics event is captured including the result type, its position in the group, and the originating query

  @analytics @positive
  Scenario: See all results selection is tracked separately from item selection
    Given a user selects "See all results for '[query]'"
    When the selection is made
    Then a see-all-results analytics event is captured distinct from individual result-selection events

  @analytics @edge
  Scenario: Zero-result searches are tracked for content/discoverability gap analysis
    Given a submitted query returns zero matches across all data domains
    When the "No search results" state is shown
    Then a zero-results analytics event is captured including the query text for discoverability gap analysis
