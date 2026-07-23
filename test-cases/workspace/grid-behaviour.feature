Feature: Grid Behaviour

  @ui @positive @smoke
  Scenario: Desktop grid renders 12-column layout
    Given a user is viewing Workspace on a desktop viewport
    When the page loads
    Then widgets render on a 12-column grid with large widgets spanning 8 columns and small widgets spanning 4 columns
    And gutters between widgets are 24px
    And the outer page margin is 40px

  @ui @positive @mobile
  Scenario: Tablet grid stacks all widgets full width
    Given a user is viewing Workspace on a tablet viewport
    When the page loads
    Then all widgets render at full width (span 12), stacked vertically
    And gutter is reduced to 16px and outer margin to 24px
    And widget height is driven by content rather than a fixed value

  @ui @mobile @edge
  Scenario: Tablet widget content paginates beyond 5 rows
    Given a widget on tablet contains a table or list with more than 5 rows
    When the content exceeds 5 items
    Then the widget paginates the content
    And does not grow widget height or introduce internal vertical scroll

  @ui @positive
  Scenario: Widget header icons appear on hover/focus (desktop)
    Given a user hovers over or keyboard-focuses a widget header on desktop
    When hover or focus occurs
    Then the drag handle, thumbs-up/thumbs-down feedback icons, export icon, and "View all" link become visible

  @ui @positive
  Scenario: Widget header icons hidden by default
    Given a widget is in its default (non-hovered, non-focused) state
    When the widget renders
    Then no drag handle, feedback icons, or export icon are visible
    And only the widget title and core content are shown

  @accessibility @positive
  Scenario: Keyboard focus reveals header icons with parity to hover
    Given a keyboard-only user tabs to a widget header
    When the widget receives keyboard focus
    Then the drag handle and header icons become visible with the same parity as the mouse-hover state
    And this satisfies WCAG 2.2 focus-visibility requirements

  @ui @positive @smoke
  Scenario: Dragging a widget snaps to nearest valid grid position and reflows others
    Given a desktop user grabs a widget's drag handle and drags it to a new position
    When the widget is dropped
    Then it snaps to the nearest valid position on the 12-column grid
    And all other widgets automatically reflow to fill any resulting gaps, leaving no empty grid spaces

  @ui @mobile @positive
  Scenario: Tablet press-and-hold activates drag mode after 500ms
    Given a tablet user presses and holds a widget's drag handle
    When the hold duration reaches 500ms
    Then drag mode activates for that widget

  @ui @mobile @negative @edge
  Scenario: Short press-and-hold does not trigger drag
    Given a tablet user presses and holds a widget's drag handle
    When the hold is released before 500ms
    Then no drag is initiated and the interaction is treated as a normal tap

  @ui @mobile @edge
  Scenario: Tablet drag is constrained to vertical movement only
    Given drag mode is active for a widget on tablet
    When the user drags
    Then the widget may only move vertically (up/down)
    And horizontal repositioning is not available on tablet

  @functional @positive
  Scenario: Widget layout persists per user across reloads
    Given a user reorders one or more widgets and later reloads or revisits Workspace
    When the page loads
    Then the widget order and layout from the user's last saved arrangement is restored exactly, persisted per user

  @analytics @positive
  Scenario: Feedback icons submit via Pendo without custom modal
    Given a user clicks the thumbs-up or thumbs-down icon on any widget header
    When the click registers
    Then feedback is submitted via the existing Pendo feedback mechanism
    And no custom feedback modal is built or displayed for this interaction

  @ui @edge
  Scenario: Grid recalculates immediately at breakpoint threshold
    Given the browser viewport is resized across the desktop/tablet breakpoint threshold
    When the breakpoint is crossed
    Then the grid recalculates immediately
    And desktop applies 8/4 column spans with 24px gutter/40px margin
    And tablet forces all widgets to span 12 with 16px gutter/24px margin

  @negative @edge
  Scenario: Manual widget resize outside assigned module is prevented
    Given a widget is manually resized by the user
    When the user attempts to resize a widget outside its assigned column span
    Then the system prevents manual resizing
    And widget dimensions are fixed to their designated large (8-col) or small (4-col) module

  @gap
  Scenario: Notifications requirement has zero design coverage
    Given the PRD requires timely in-app and email alerts for relevant events
    When the Workspace grid and widget catalogue are reviewed
    Then no notification centre, preference settings, or alert mechanism is present in any supplied design asset
    And this design coverage gap requires Product Owner clarification

  @gap
  Scenario: High-level reporting widget has zero design coverage
    Given the PRD requires a reporting widget showing client count, WIP, overdue tasks, and exceptions
    When the widget catalogue and grid mockups are reviewed
    Then no such reporting widget is present in any supplied design asset
    And this design coverage gap requires Product Owner clarification
