Feature: Launchpad

  @ui @positive @smoke
  Scenario: Personalised greeting with overdue message displays on load
    Given a user loads the Workspace page with an active session
    When the Launchpad renders
    Then a personalised greeting displays the user's first name
    And the greeting includes a dynamic overdue-item message such as "Hello Craig, You usually prepare annual statements around this time of year, and you have 3 items overdue this week"
    And a "Start a task" label appears above a row of Quick Action shortcut buttons

  @ui @positive
  Scenario: Corporate Messenger entitled user sees ASIC form defaults
    Given a user entitled to Corporate Messenger loads the Workspace page
    When the Launchpad widget loads its default Quick Actions
    Then the default set includes Trust Distribution Resolution/Minutes, Standard Company, Discretionary Trust, ASIC Form 484 (Change of Address), and ASIC Form 362 (Nominate a Registered Agent)

  @ui @positive
  Scenario: Non-Corporate-Messenger user sees non-ASIC defaults
    Given a user NOT entitled to Corporate Messenger loads the Workspace page
    When the Launchpad widget loads its default Quick Actions
    Then the default set instead includes Trust Distribution Resolution/Minutes, Standard Company, Discretionary Trust, Division 7A Loan, and Investment Strategy
    And no ASIC-form shortcuts are shown

  @ui @positive @smoke
  Scenario: Clicking a Quick Action launches mapped workflow pre-filled
    Given the Launchpad is in its default non-edit state
    When the user clicks a Quick Action button
    Then the mapped workflow launches via Forms Intent Mapping
    And the associated document/form is pre-filled

  @ui @positive
  Scenario: Quick Action pre-fills client-file context when available
    Given the Launchpad is in its default state
    And client-file context is available for the current session
    When the user clicks a Quick Action button
    Then the mapped workflow launches
    And required context fields are pre-filled per the PRD's "Workflow shortcuts" requirement

  @ui @negative @edge @gap
  Scenario: Quick Action click with no client-file context available
    Given the Launchpad is in its default state
    And no client-file context is available for the current session
    When the user clicks a Quick Action button
    Then the mapped workflow launches via Forms Intent Mapping
    And the form opens without pre-filled client context
    And no error is shown to the user

  @ui @positive @smoke
  Scenario: Create a new document navigates to full documents list
    Given the Launchpad is in its default state
    When the user clicks "+ Create a new document"
    Then the user is navigated to the full documents/forms list

  @ui @positive @smoke
  Scenario: Start identity verification navigates to IDV start page
    Given the Launchpad is in its default state
    When the user clicks "Start identity verification"
    Then the user is navigated to the Identity Verification start page

  @ui @positive
  Scenario: Edit pencil icon appears on hover with pointer input
    Given desktop/pointer input is detected
    When the user hovers over the "Quick Actions" area
    Then an edit (pencil) icon appears beside the label

  @ui @positive
  Scenario: Edit pencil icon hides when pointer leaves area
    Given desktop/pointer input is detected
    And the edit (pencil) icon is currently visible from a hover
    When the pointer leaves the Quick Actions area
    Then the edit (pencil) icon is hidden

  @ui @mobile @positive
  Scenario: Edit pencil icon always visible on tablet/touch input
    Given tablet/touch input is detected with no hover capability
    When the Launchpad renders
    Then the edit (pencil) icon is always visible
    And the icon is not hover-gated

  @ui @positive @smoke
  Scenario: Clicking edit icon enters Customise/Edit mode with chevrons
    Given the edit icon is visible
    When the user clicks the edit icon
    Then the Launchpad enters Customise/Edit mode
    And every Quick Action button displays a chevron indicator marking it as replaceable

  @ui @mobile @positive
  Scenario: Tapping edit icon enters Edit mode on tablet
    Given tablet/touch input is detected
    And the edit (pencil) icon is visible
    When the user taps the edit icon
    Then the Launchpad enters Customise/Edit mode
    And every Quick Action button displays a chevron indicator

  @ui @positive @smoke
  Scenario: Clicking a Quick Action in edit mode opens Replace panel
    Given edit mode is active
    When the user clicks a Quick Action button
    Then a "Replace Quick Action" panel opens
    And the panel contains a searchable autocomplete field
    And the panel contains a categorised menu including groups such as "COMPANY FORMATIONS" and "TRUSTS" with selectable documents/workflows

  @ui @negative
  Scenario: Replace panel shows no-match message for unmatched search
    Given the Replace Quick Action panel is open
    When the user types a search term matching no documents
    Then the panel displays "No documents match your search."

  @ui @edge
  Scenario: Search term with only whitespace shows no-match message
    Given the Replace Quick Action panel is open
    When the user types a search term consisting only of whitespace characters
    Then the panel displays "No documents match your search."

  @ui @positive
  Scenario: Search autocomplete filters matching documents as user types
    Given the Replace Quick Action panel is open
    When the user types a search term matching one or more documents
    Then the autocomplete field and categorised menu update to show only matching documents

  @ui @positive @edge
  Scenario: Document already assigned to another Quick Action shown disabled
    Given the Replace Quick Action panel is open
    And a document is already assigned to another active Quick Action
    When the list renders
    Then that document remains visible in the list
    And it is shown disabled
    And it cannot be re-selected
    And duplicate shortcuts are prevented

  @ui @positive @smoke
  Scenario: Selecting an available document updates button label immediately without Save
    Given the Replace Quick Action panel is open
    When the user selects an available document
    Then the corresponding button's label updates immediately
    And no separate "Save" action is required
    And the change persists for that user

  @ui @positive
  Scenario: Exit edit mode by clicking edit icon again
    Given edit mode is active
    When the user clicks the edit icon again
    Then Edit mode exits
    And the Launchpad returns to its default state

  @ui @positive
  Scenario: Exit edit mode by clicking outside Quick Actions area
    Given edit mode is active
    When the user clicks outside the Quick Actions area
    Then Edit mode exits
    And the Launchpad returns to its default state

  @ui @positive @accessibility
  Scenario: Exit edit mode by pressing Esc
    Given edit mode is active
    When the user presses Esc
    Then Edit mode exits
    And the Launchpad returns to its default state

  @ui @mobile @positive
  Scenario: Exit edit mode by tapping edit icon again on tablet
    Given tablet/touch input is detected
    And edit mode is active
    When the user taps the edit icon again
    Then Edit mode exits
    And the Launchpad returns to its default state

  @ui @mobile @edge
  Scenario: Start a Task row overflows with horizontal scroll on tablet width
    Given viewport is tablet width
    And the Start a Task button row exceeds available width
    When the row renders
    Then buttons overflow with horizontal scroll
    And buttons do not wrap
    And buttons do not truncate

  @accessibility @gap
  Scenario: Keyboard-only user can tab through Quick Action buttons with visible focus
    Given a keyboard-only user is navigating the Launchpad
    When they tab through the Quick Action buttons
    Then each Quick Action button receives a visible focus indicator
    And each Quick Action button is operable via Enter or Space
    And this fulfils the WCAG 2.2 focus-visible baseline pending explicit UX confirmation

  @accessibility @gap
  Scenario: Keyboard-only user can operate edit icon and Replace panel controls
    Given a keyboard-only user is navigating the Launchpad
    When they tab to the edit icon
    Then the edit icon receives a visible focus indicator
    And the edit icon is operable via Enter or Space
    When they tab into the Replace Quick Action search field and menu items
    Then the search field and each menu item receive a visible focus indicator
    And each menu item is operable via Enter or Space

  @accessibility @gap
  Scenario: Focus order through Launchpad widget is logical and documented
    Given a keyboard-only user is navigating the Launchpad
    When they tab sequentially through the greeting banner, Quick Action buttons, edit icon, and Replace Quick Action autocomplete/menu
    Then focus moves in a logical, predictable order
    And this baseline is flagged as pending explicit UX/ARIA confirmation since neither source PDF specifies keyboard interaction or ARIA labelling for these elements

  @ui @positive @analytics
  Scenario: Pendo event fires when a Quick Action shortcut is clicked
    Given the Launchpad is in its default state
    And Pendo analytics tracking is enabled
    When the user clicks a Quick Action button
    Then a Pendo analytics event is recorded for the Quick Action click
    And the event includes the shortcut/document identifier

  @ui @positive @analytics
  Scenario: Pendo event fires when a Quick Action is replaced in edit mode
    Given edit mode is active
    And Pendo analytics tracking is enabled
    When the user selects a replacement document in the Replace Quick Action panel
    Then a Pendo analytics event is recorded for the shortcut replacement
    And the event includes the old and new document identifiers

  @ui @positive @analytics
  Scenario: Pendo event fires when Create a new document or Start identity verification is clicked
    Given the Launchpad is in its default state
    And Pendo analytics tracking is enabled
    When the user clicks "+ Create a new document" or "Start identity verification"
    Then a Pendo analytics event is recorded identifying which action was taken

  @ui @positive
  Scenario: Customised Quick Action selection persists after logout/login
    Given a user has replaced a Quick Action shortcut
    When they log out
    And they log back in
    Then their customised shortcut selection persists per-user

  @ui @edge @negative
  Scenario: Persisted customisation is scoped to the individual user, not shared
    Given User A has replaced a Quick Action shortcut
    When User B logs into the same Workspace on the same device
    Then User B sees their own default or previously customised Quick Actions
    And User A's customisation does not appear for User B

  @ui @negative
  Scenario: Replace Quick Action list excludes documents tied to unavailable feature
    Given a user lacks access to a feature associated with a given document such as ASIC Forms without Corporate Messenger entitlement
    When the Replace Quick Action list is built
    Then documents tied to that feature are excluded from the selectable list for that user

  @ui @edge @negative
  Scenario: Default Quick Actions never include entitlement-restricted documents
    Given a user lacks Corporate Messenger entitlement
    When the Launchpad renders default Quick Actions
    Then no ASIC-form shortcuts appear among the defaults
    And the Replace Quick Action panel also excludes ASIC-form documents for that user

  @ui @edge @gap
  Scenario: Default shortcut mapping depends on external Forms Intent Mapping configuration
    Given the Forms Intent Mapping spreadsheet defines the default shortcut-to-workflow mapping
    And this spreadsheet is an external content/config dependency not included in the provided design package
    When the Launchpad loads default Quick Actions
    Then the rendered defaults match the currently configured Forms Intent Mapping
    And this dependency is flagged for explicit confirmation before release

  @ui @negative @edge
  Scenario: Overdue-item count of zero displays an appropriate greeting variant
    Given a user loads the Workspace page with an active session
    And the user has zero overdue items this week
    When the Launchpad renders
    Then the personalised greeting displays the user's first name
    And the greeting does not display a false overdue-item count

  @mobile @ui @positive
  Scenario: Launchpad renders correctly on tablet viewport in default state
    Given a user loads the Workspace page on a tablet-width viewport
    When the Launchpad renders in its default state
    Then the greeting, Start a task label, and Quick Action buttons all display correctly
    And the always-visible edit icon is shown per touch-input behaviour

  @edge @negative
  Scenario: Replace Quick Action panel search is case-insensitive
    Given the Replace Quick Action panel is open
    When the user types a search term in a different case than the stored document name
    Then matching documents are still returned
    And the panel does not incorrectly display "No documents match your search."
