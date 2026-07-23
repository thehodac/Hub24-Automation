Feature: Grid Behaviour drag and drop

  @ui @positive @smoke
  Scenario: Desktop grid renders 12-column layout with correct gutters and margin
    Given the Workspace page loads on desktop
    When it renders
    Then widgets lay out on a 12-column grid
    And the grid uses 24px gutters
    And the grid uses a 40px outer margin

  @ui @positive
  Scenario: Wide widgets occupy 8 columns on desktop
    Given the Workspace page loads on desktop
    When it renders
    Then each wide widget occupies 8 columns
    And each wide widget has a fixed height of 436px

  @ui @positive
  Scenario: Small widgets occupy 4 columns on desktop
    Given the Workspace page loads on desktop
    When it renders
    Then each small widget occupies 4 columns
    And each small widget has a fixed height of 436px

  @ui @positive @edge
  Scenario: All desktop widgets share a fixed 436px height regardless of content length
    Given the Workspace page loads on desktop
    And a widget contains more content than another widget of the same size
    When the grid renders
    Then both widgets render at a fixed height of 436px
    And content overflow is handled without changing widget height

  @ui @positive @smoke @mobile
  Scenario: Tablet layout stacks all widgets in a single full-width column
    Given the Workspace page loads on tablet
    When it renders
    Then all widgets, wide and small, span the full 12 columns
    And all widgets are arranged in a single stacked column

  @ui @positive @mobile
  Scenario: Tablet layout uses 16px gutters and 24px outer margin
    Given the Workspace page loads on tablet
    When it renders
    Then the grid uses 16px gutters
    And the grid uses a 24px outer margin

  @ui @positive @mobile
  Scenario: Tablet stacked widget order matches desktop layout order
    Given the Workspace page has a known widget order on desktop
    When the same Workspace page renders on tablet
    Then the stacked widgets appear in the same top-to-bottom order as the desktop layout

  @ui @positive @mobile @edge
  Scenario: Tablet widget height is content-driven rather than fixed
    Given the Workspace page loads on tablet
    And a widget contains more content than another widget
    When the grid renders
    Then each widget's height reflects its own content
    And widget heights are not fixed at 436px as on desktop

  @ui @edge @gap
  Scenario: Grid switches from desktop to tablet layout when viewport crosses the responsive breakpoint
    Given the Workspace page is open at a desktop viewport width
    When the viewport width is reduced across the responsive breakpoint
    Then the grid switches from the desktop multi-column layout to the single-column 100%-width stacked tablet layout
    And this scenario cannot be executed deterministically because the breakpoint pixel value is not specified in the design (flagged design gap)

  @negative @gap
  Scenario: Breakpoint pixel value is undefined, blocking deterministic boundary testing
    Given AC-03 requires a specific desktop-to-tablet breakpoint
    When the functional spec is reviewed for the breakpoint pixel value
    Then the value is documented as TBD
    And no deterministic pass/fail boundary test can be authored until the value is defined
    And this is flagged as a design coverage gap

  @ui @positive
  Scenario: Drag handle appears in widget header on hover
    Given a widget is in its default non-dragging state on desktop
    When the user hovers over the widget
    Then a grip-dots-vertical drag handle icon appears in the widget header

  @ui @positive @edge
  Scenario: Headerless or image-led widget shows drag handle at fixed default position on hover
    Given a headerless or image-led widget is in its default non-dragging state on desktop
    When the user hovers over the widget
    Then a drag handle appears at a fixed default position on the widget

  @ui @positive @smoke
  Scenario: Clicking and holding the drag handle lifts the widget and shows a placeholder
    Given the drag handle is visible on a widget on desktop
    When the user clicks and holds the handle
    Then the widget lifts into a dragging state
    And the widget's original slot shows a placeholder

  @ui @positive
  Scenario: Dragged widget can be moved in any direction on desktop
    Given a widget is in a dragging state on desktop
    When the user moves the pointer up, down, left, or right
    Then the widget follows the pointer movement in the corresponding direction

  @ui @positive @smoke
  Scenario: Releasing a dragged widget snaps it into place and reflows the grid without gaps or overlaps
    Given a widget is being dragged on desktop
    When the user releases it
    Then the widget snaps to the nearest valid grid position
    And all other widgets automatically reflow
    And no empty gaps remain in the grid
    And no widgets overlap

  @ui @positive
  Scenario: Adjacent large widgets expand to full width when three small widgets complete a row
    Given three small 4-column widgets complete a single grid row
    When the layout reflows
    Then adjacent large 8-column widgets automatically expand to occupy the full 12 columns

  @ui @positive
  Scenario: Two small widgets in a row grow to fill available row space
    Given two small widgets occupy a single grid row
    When the layout reflows
    Then the two small widgets grow to fill the available row space

  @ui @positive @edge
  Scenario: Lone small widget in a row grows to fill available row space
    Given one lone small widget occupies a single grid row
    When the layout reflows
    Then the lone small widget grows to fill the available row space

  @negative
  Scenario: Widget resizing is not permitted in this release
    Given a widget is selected or being dragged
    When the user attempts to resize the widget
    Then the resize action is not permitted
    And the widget dimensions remain unchanged

  @ui @positive @mobile
  Scenario: Tablet drag activates only after a 500ms hold on the handle
    Given a widget's drag handle is pressed on tablet
    When the user holds the handle for 500ms
    Then dragging activates
    And movement is constrained to vertical up/down reordering only

  @negative @mobile
  Scenario: Tablet drag does not activate if handle is released before 500ms
    Given a widget's drag handle is pressed on tablet
    When the user releases the handle before 500ms has elapsed
    Then dragging does not activate
    And the underlying page scroll is not interrupted

  @ui @positive @mobile @edge
  Scenario: Tablet drag movement is constrained to vertical reordering only
    Given a widget drag has activated on tablet after the 500ms hold
    When the user attempts to move the widget horizontally
    Then the widget movement is constrained to vertical up/down reordering only

  @ui @positive @mobile
  Scenario: Tapping a tablet widget outside interactive controls enters active/selected state
    Given a widget is displayed on tablet
    When the user taps anywhere on the widget other than an interactive control
    Then the widget enters an active/selected state

  @negative @mobile
  Scenario: Drag does not initiate from outside the tablet drag handle
    Given a widget is displayed on tablet
    When the user attempts to drag from anywhere other than the drag handle
    Then the drag does not initiate

  @ui @positive @edge
  Scenario: Widget for a disabled feature is hidden and other widgets reflow to fill the space
    Given the Workspace grid renders for a user
    And a widget's associated feature is not enabled for that user
    When the grid renders
    Then the widget is hidden
    And the widget does not occupy a grid slot
    And other widgets reflow to fill the space

  @ui @positive @gap
  Scenario: Rearranged layout persists after navigating away and returning to Workspace
    Given a user has rearranged widgets via drag-and-drop
    When they navigate away from Workspace and return
    Then the rearranged layout persists for that user
    And the persistence mechanism is a flagged design gap pending definition

  @ui @positive @gap
  Scenario: Rearranged layout persists after logout and login
    Given a user has rearranged widgets via drag-and-drop
    When they log out and log back in
    Then the rearranged layout persists for that user
    And the persistence mechanism is a flagged design gap pending definition

  @negative @gap
  Scenario: Layout persistence mechanism is undefined, blocking cross-session/device sync verification
    Given AC-12 requires layout persistence for a user
    When the design is reviewed for the save trigger, storage scope, and cross-session/device sync behaviour
    Then these details are undefined in the Deliverable Breakdown
    And cross-device sync cannot be verified until the persistence mechanism is specified
    And this is flagged as a design coverage gap

  @ui @positive @analytics
  Scenario: Clicking thumbs-up or thumbs-down on a feedback-enabled widget launches the Pendo feedback flow
    Given a feedback-enabled widget such as Trending Documents, Continue Work, Upcoming Deadlines, Outstanding Signatures, Lodgement Status, or Reporting Snapshot is displayed
    When the user clicks its thumbs-up or thumbs-down icon
    Then the click launches the Pendo feedback flow
    And Pendo owns the pop-up UI and response tracking

  @negative @analytics
  Scenario: No custom feedback modal is built for feedback-enabled widgets
    Given a feedback-enabled widget is displayed
    When the user clicks its thumbs-up or thumbs-down icon
    Then no custom feedback modal is rendered by the application
    And the feedback UI is fully owned by Pendo

  @accessibility @positive
  Scenario: Drag handle becomes visible when a widget receives keyboard focus
    Given a keyboard-only user tabs to a widget
    When the widget receives focus
    Then its drag handle becomes visible
    And the visibility matches the hover-triggered visibility for pointer users

  @accessibility @negative @gap
  Scenario: No keyboard-operable move mechanism or ARIA-live reflow announcement is defined
    Given a keyboard-only user has focused a widget and its drag handle is visible
    When the user attempts to reorder the widget using the keyboard alone
    Then no keyboard-operable move mechanism such as arrow-key reorder or a move up/down menu action is specified
    And no ARIA-live announcement of grid reflow is defined
    And this is flagged as a design coverage gap affecting AC-14

  @ui @positive @edge
  Scenario: Widget released outside a valid drop zone auto-snaps back to the nearest valid position
    Given a widget is mid-drag on desktop
    When the user releases it outside any valid drop zone
    Then the widget automatically snaps back to the nearest valid grid position
    And no invalid-drop or error state is shown

  @ui @positive @smoke
  Scenario: Desktop widget order matches the reference mockup
    Given the Workspace grid has rendered on desktop per the reference mockup
    When the rendered order is compared to the design
    Then the first row shows Upcoming Deadlines at 8 columns and Continue Work at 4 columns
    And the second row shows Lodgements Status at 8 columns and Popular Documents at 4 columns
    And the third row shows Outstanding Signatures at 8 columns and a promotional or event card at 4 columns

  @ui @positive @mobile
  Scenario: Tablet table/list widget with more than five items uses numbered pagination
    Given the tablet viewport is active
    And a table or list widget such as Upcoming Deadlines or Popular Documents contains more than five items
    When the widget renders
    Then it uses numbered pagination
    And it does not use internal vertical scroll

  @ui @positive @mobile @edge
  Scenario: Tablet table/list widget with five or fewer items does not show pagination
    Given the tablet viewport is active
    And a table or list widget contains five or fewer items
    When the widget renders
    Then no numbered pagination controls are shown
