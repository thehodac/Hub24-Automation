Feature: Popular Documents Widget

  @ui @positive @smoke
  Scenario: Widget header and primary tabs render on Workspace load
    Given a user loads Workspace
    When the Popular Documents widget renders
    Then a header "Popular Documents" is displayed
    And two primary tabs "For your practice" and "Across NowInfinity" are displayed

  @ui @positive @smoke
  Scenario: Secondary toggle displays Documentation Suite and ASIC Forms options
    Given a user loads Workspace
    When the Popular Documents widget renders
    Then a secondary toggle is displayed
    And the toggle contains "Documentation Suite" and "ASIC Forms" options

  @ui @positive
  Scenario: Documentation Suite is the default active toggle state
    Given a user loads Workspace for the first time in a session
    When the Popular Documents widget renders
    Then "For your practice" is the active primary tab
    And "Documentation Suite" is the active secondary toggle

  @ui @negative @edge
  Scenario: ASIC Forms toggle is hidden for users without Corporate Messenger access
    Given a user does not have access to ASIC-related functionality
    And the user has no Corporate Messenger
    When the widget renders
    Then the "ASIC Forms" toggle is hidden
    And only the Documentation Suite dataset is shown

  @ui @positive
  Scenario: ASIC Forms toggle is visible for users with Corporate Messenger access
    Given a user has access to ASIC-related functionality
    And the user has Corporate Messenger
    When the widget renders
    Then the "ASIC Forms" toggle is visible
    And the user can switch between Documentation Suite and ASIC Forms datasets

  @ui @positive @smoke
  Scenario: Documentation Suite list displays up to 10 ranked rows with icon, name, category, and usage count
    Given the "For your practice" tab is active
    And the "Documentation Suite" toggle is active
    When the list renders
    Then up to 10 ranked rows are displayed
    And each row shows a category icon, document name, category/form label, and a usage count
    And rows are ordered by usage count descending

  @ui @edge
  Scenario: Documentation Suite list caps display at 10 rows when more than 10 documents have usage data
    Given the "Documentation Suite" toggle is active
    And more than 10 documents have recorded usage
    When the list renders
    Then only the top 10 ranked rows are displayed
    And no pagination or "show more" control is present

  @ui @edge @gap
  Scenario: Fewer than 10 documents with usage data renders a partial list
    Given the "Documentation Suite" toggle is active
    And fewer than 10 documents have recorded usage
    When the list renders
    Then only the available ranked rows are displayed
    And no empty-state copy or placeholder rows are shown, as no empty state is defined in the spec

  @ui @positive
  Scenario: ASIC Forms list displays document name and form label without a usage count
    Given the "ASIC Forms" toggle is active
    When the list renders
    Then each row shows a document name and form number/label
    And no usage count is visible on any row

  @ui @negative
  Scenario: Usage count column is absent, not merely blank, on ASIC Forms rows
    Given the "ASIC Forms" toggle is active
    And the list has rendered
    When a row is inspected
    Then no usage-count element is present in the row markup
    And no zero or dash placeholder is rendered in its place

  @ui @positive @accessibility
  Scenario: Drag handle and feedback icons are hidden by default and revealed on hover
    Given the widget is in its default state
    When the user has not hovered or focused it
    Then the drag handle is hidden
    And the thumbs-up/thumbs-down icons are hidden
    When the user hovers over the widget
    Then the drag handle and thumbs-up/thumbs-down icons become visible

  @accessibility @positive
  Scenario: Drag handle and feedback icons are revealed on keyboard focus
    Given the widget is in its default state
    When the user moves keyboard focus onto the widget
    Then the drag handle becomes visible
    And the thumbs-up/thumbs-down icons become visible

  @ui @edge
  Scenario: Scrollbar appears on hover when list content exceeds the visible area
    Given the list content exceeds the widget's visible area
    When the user hovers over the widget
    Then a scrollbar appears
    And the header and toggles remain fixed in place

  @ui @edge @accessibility
  Scenario: Scrollbar appears on keyboard focus and during active scroll, and hides otherwise
    Given the list content exceeds the widget's visible area
    When the user keyboard-focuses the widget or actively scrolls it
    Then the scrollbar is visible
    When the user is not hovering, focusing, or actively scrolling
    Then the scrollbar is hidden

  @ui @positive @smoke
  Scenario: Clicking a document row opens the document-creation interview
    Given a document row is displayed
    When the user clicks the row
    Then the relevant document-creation interview/workflow opens
    And no static document view is shown

  @accessibility @positive @smoke
  Scenario: Pressing Enter on a focused document row opens the document-creation interview
    Given a document row is focused via keyboard
    When the user presses Enter
    Then the relevant document-creation interview/workflow opens
    And not a static document view

  @accessibility @positive
  Scenario: Pressing Space on a focused document row opens the document-creation interview
    Given a document row is focused via keyboard
    When the user presses Space
    Then the relevant document-creation interview/workflow opens
    And not a static document view

  @analytics @positive @smoke
  Scenario: Clicking thumbs-up launches the Pendo feedback flow
    Given the widget is visible
    And the thumbs-up icon is visible on hover or focus
    When the user clicks thumbs-up
    Then the Pendo feedback flow launches

  @analytics @positive
  Scenario: Clicking thumbs-down launches the Pendo feedback flow
    Given the widget is visible
    And the thumbs-down icon is visible on hover or focus
    When the user clicks thumbs-down
    Then the Pendo feedback flow launches

  @ui @positive
  Scenario: Selecting Across NowInfinity tab switches list to platform-wide usage data
    Given the widget has rendered with "For your practice" active
    When the user selects the "Across NowInfinity" tab
    Then the list switches to platform-wide usage data across all NowInfinity practices
    And the data is independent of the current practice's own usage

  @ui @edge
  Scenario: Across NowInfinity data does not change when the current practice's usage changes
    Given the "Across NowInfinity" tab is active
    And the current practice's own document usage changes
    When the widget re-renders
    Then the platform-wide ranking is unaffected by the current practice's own usage change

  @ui @negative
  Scenario: No user-configurable sort or filter controls are present on the widget
    Given the widget has rendered
    When the widget is inspected
    Then no sort control is present
    And no filter control is present
    And the only content-scoping controls are the primary tabs and the Documentation Suite/ASIC Forms toggle

  @ui @negative @edge
  Scenario: List order remains fixed by usage-count ranking and is not user-reorderable
    Given the widget has rendered with a ranked list
    When the user attempts to interact with a row other than clicking or keyboard-activating it
    Then the row order does not change
    And list order remains fixed by usage-count ranking

  @ui @negative
  Scenario: No export control is present on the Popular Documents widget
    Given the widget has rendered
    When the widget is inspected
    Then no export control is present
    And Popular Documents is excluded from the exportable-widget list

  @negative @gap
  Scenario: Popular Documents widget is absent from the workspace-wide export-all action
    Given a workspace-level "export all widgets" action exists
    When the export-all action is triggered
    Then Popular Documents data is not included in the export output
    And this exclusion behaviour is inferred from AC-10 as the spec does not define export-all interaction explicitly

  @accessibility @positive
  Scenario: Keyboard-only user can tab through all document cards with visible focus indicator
    Given a keyboard-only user is navigating the widget
    When they press Tab to move through document cards
    Then each card is reachable via keyboard
    And each focused card shows a visible focus indicator matching its hover styling

  @accessibility @edge
  Scenario: Focus order through document cards follows the visible ranked list order
    Given a keyboard-only user is navigating the widget
    When they press Tab repeatedly through the document cards
    Then focus moves in the same order as the visible ranked list, top to bottom

  @ui @edge @gap
  Scenario: Usage counts reflect static aggregate totals rather than a rolling monthly window in Release 1
    Given Release 1 is active
    When the widget populates rankings
    Then usage counts reflect static/aggregate totals
    And dynamic monthly recalculation is out of scope for Release 1
    And the spec does not define the refresh cadence for the aggregate totals, which is flagged as a gap

  @gap @edge
  Scenario: No mobile layout is explicitly defined for the Popular Documents widget
    Given the widget is viewed on a mobile viewport
    When the widget renders
    Then no mobile-specific layout, breakpoint behaviour, or touch interaction is defined in this spec
    And this is flagged as a design coverage gap requiring UX definition

  @mobile @gap @edge
  Scenario: Hover-only affordances have no defined touch equivalent on mobile/tablet
    Given the widget is viewed on a touch-only device with no hover capability
    When the user attempts to reveal the drag handle and thumbs-up/thumbs-down icons
    Then the spec does not define a tap or long-press equivalent to hover/focus reveal
    And this is flagged as a gap for touch-device behaviour

  @mobile @gap
  Scenario: Scrollbar-on-hover behaviour has no defined equivalent for touch scrolling
    Given the widget is viewed on a touch device
    And the list content exceeds the visible area
    When the user scrolls the list via touch
    Then the spec does not define whether a scrollbar indicator appears during touch scroll
    And this is flagged as a gap

  @gap @negative
  Scenario: No error or fallback state is defined if usage-count data fails to load
    Given the widget attempts to load usage-count data
    When the data request fails or times out
    Then no error state, retry control, or fallback copy is defined in this spec
    And this is flagged as a design coverage gap
