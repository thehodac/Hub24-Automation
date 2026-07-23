Feature: Continue Work Widget

  @ui @positive @smoke
  Scenario: Widget displays in-progress document card with all required fields
    Given a user has a document with saved state in Draft status
    When they load Workspace
    Then the Continue Work widget displays it as a card
    And the card shows document type, entity/workflow name, a status badge, a description line, and "Last edited by [name], [date/time]"

  @ui @positive
  Scenario: Widget displays card for document in Needs Signature status
    Given a user has a document with saved state in Needs Signature status
    When they load Workspace
    Then the Continue Work widget displays it as a card
    And the status badge reads Needs Signature

  @ui @positive
  Scenario: Widget displays card for document in Payment Pending status
    Given a user has a document with saved state in Payment Pending status
    When they load Workspace
    Then the Continue Work widget displays it as a card
    And the status badge reads Payment Pending

  @ui @positive
  Scenario: Widget displays card for document in Awaiting ASIC status
    Given a user has a document with saved state in Awaiting ASIC status
    When they load Workspace
    Then the Continue Work widget displays it as a card
    And the status badge reads Awaiting ASIC

  @ui @positive @smoke
  Scenario: Cards are sorted most-recently-updated first
    Given a user has multiple in-progress documents and workflows with different last-updated timestamps
    When they load Workspace
    Then the Continue Work widget displays the cards ordered from most-recently-updated to least-recently-updated

  @ui @positive
  Scenario: Card ordering updates after editing an older item
    Given a user has multiple in-progress documents displayed in the Continue Work widget
    When they resume and save further edits to a document that was not the most recently updated
    And they reload Workspace
    Then that document's card moves to the top of the list as the most-recently-updated item

  @ui @positive @smoke
  Scenario: Empty state displays when there are zero in-progress items
    Given a user has zero in-progress documents or workflows
    When the Continue Work widget renders
    Then an empty state displays with heading "Continue Work"
    And message "No work to continue yet"
    And subtext "Drafts and in-progress documents will appear here once you've started working on them"
    And a "Create a new document" CTA button is displayed

  @ui @positive @smoke
  Scenario: Create a new document CTA navigates to documents/forms list
    Given the empty state is displayed in the Continue Work widget
    When the user clicks "Create a new document"
    Then they are navigated to the original documents/forms list

  @ui @accessibility @positive
  Scenario: Create a new document CTA is keyboard operable
    Given the empty state is displayed in the Continue Work widget
    When the user tabs to focus the "Create a new document" button
    And presses Enter
    Then they are navigated to the original documents/forms list

  @ui @positive
  Scenario: Drag handle and feedback icons appear on hover
    Given the widget is in its default state
    When the user hovers over a document card
    Then the drag handle becomes visible
    And the thumbs-up and thumbs-down icons become visible

  @ui @accessibility @positive
  Scenario: Drag handle and feedback icons appear on keyboard focus
    Given the widget is in its default state
    When the user tabs to keyboard-focus a document card
    Then the drag handle becomes visible
    And the thumbs-up and thumbs-down icons become visible

  @ui @edge @positive
  Scenario: Drag handle and feedback icons hide when hover/focus ends
    Given the drag handle and feedback icons are visible on a hovered card
    When the user moves the pointer away from the card and no card is keyboard-focused
    Then the drag handle and thumbs-up/thumbs-down icons return to hidden

  @ui @edge @positive
  Scenario: Scrollbar appears on hover when card content overflows
    Given the widget contains enough cards that content overflows the visible list area
    When the user hovers over the list or actively scrolls it
    Then a scrollbar appears

  @ui @edge @positive
  Scenario: Scrollbar hides when not hovering or scrolling
    Given the widget list content overflows and a scrollbar is currently visible
    When the user stops hovering over the list and is not actively scrolling
    Then the scrollbar returns to hidden

  @ui @edge @negative
  Scenario: No scrollbar appears when content does not overflow
    Given the widget contains few enough cards that content fits within the visible list area
    When the user hovers over the list
    Then no scrollbar appears

  @ui @positive @smoke
  Scenario: Clicking a card resumes the saved workflow with pre-filled data at the correct step
    Given a document/workflow card is displayed with previously entered data saved server-side
    When the user clicks the card
    Then they are returned directly into the saved workflow
    And all previously entered data is pre-filled
    And the workflow resumes at the exact step where they left off

  @ui @accessibility @positive @smoke
  Scenario: Pressing Enter on a focused card resumes the saved workflow
    Given a document/workflow card is keyboard-focused
    When the user presses Enter
    Then they are returned directly into the saved workflow
    And all previously entered data is pre-filled
    And the workflow resumes at the exact step where they left off

  @ui @accessibility @positive
  Scenario: Pressing Space on a focused card resumes the saved workflow
    Given a document/workflow card is keyboard-focused
    When the user presses Space
    Then they are returned directly into the saved workflow
    And all previously entered data is pre-filled
    And the workflow resumes at the exact step where they left off

  @ui @analytics @positive @smoke
  Scenario: Clicking thumbs-up launches the Pendo feedback flow
    Given the Continue Work widget is visible
    When the user clicks the thumbs-up icon on a card
    Then the Pendo feedback flow launches

  @ui @analytics @positive
  Scenario: Clicking thumbs-down launches the Pendo feedback flow
    Given the Continue Work widget is visible
    When the user clicks the thumbs-down icon on a card
    Then the Pendo feedback flow launches

  @ui @analytics @edge @negative
  Scenario: Clicking thumbs-up/down does not also trigger card navigation
    Given the Continue Work widget is visible with at least one card
    When the user clicks the thumbs-up or thumbs-down icon on a card
    Then the Pendo feedback flow launches
    And the user is not navigated into the saved workflow

  @ui @negative @edge
  Scenario: No filter, sort, or export controls are present on the widget
    Given the Continue Work widget has rendered with in-progress items
    When the widget is viewed
    Then no filter controls are present
    And no sort controls are present
    And no export controls are present
    And item order is fixed by most-recently-updated

  @ui @positive @edge
  Scenario: Document is removed from the widget once it reaches a completed/final state
    Given a document previously appeared in the Continue Work widget with status Draft
    When the document reaches a completed/final state that is no longer Draft, Needs Signature, Payment Pending, or Awaiting ASIC
    And the widget renders
    Then that document no longer appears in the Continue Work widget

  @ui @edge @positive
  Scenario: Widget scope remains limited to incomplete/in-progress work only
    Given a user has both in-progress documents and fully completed documents
    When the widget renders
    Then only the in-progress documents in Draft, Needs Signature, Payment Pending, or Awaiting ASIC status are displayed
    And completed documents are excluded

  @ui @negative @edge
  Scenario: Out-of-scope Release 1 workflow types do not appear in the widget
    Given a user has in-progress work of types add multiple companies, add existing trust, add existing fund, new I&DV request, or make payment
    When the widget renders
    Then none of those in-progress workflow types are displayed
    And only saved documents are surfaced

  @ui @positive @smoke
  Scenario: Widget surfaces only saved documents in Release 1
    Given Release 1 is active
    And a user has an in-progress saved document
    When the widget populates
    Then the saved document is displayed as a card

  @accessibility @positive @smoke
  Scenario: Keyboard-only user can tab through all document cards
    Given a keyboard-only user is navigating the widget
    And multiple document cards are displayed
    When they press Tab repeatedly
    Then each card is reachable in sequence via keyboard focus

  @accessibility @positive
  Scenario: Enter/Space on a focused card opens the saved workflow for keyboard-only users
    Given a keyboard-only user has tabbed to a document card and it is focused
    When they press Enter or Space
    Then the saved workflow opens

  @accessibility @edge @positive
  Scenario: Focus order and visible focus indicator are correct across cards
    Given multiple document cards are displayed in the widget
    When a keyboard-only user tabs through the cards
    Then a visible focus indicator is shown on the currently focused card
    And focus order follows the visual order of the cards

  @negative @edge @ui
  Scenario: Locally cached data is not used to populate the widget
    Given a user's in-progress document data exists both server-side and in a stale local cache on the user's device
    When the widget retrieves data to display
    Then the data shown is sourced from server-side storage
    And the locally cached copy is not used

  @negative @edge
  Scenario: Widget does not render stale local data after server-side deletion
    Given a document was previously cached locally on the user's device
    And the document has since been deleted or completed server-side
    When the widget renders
    Then the widget does not display the stale locally cached document

  @mobile @ui @positive
  Scenario: Widget renders correctly on a mobile viewport
    Given a user loads Workspace on a mobile viewport
    And they have an in-progress document
    When the Continue Work widget renders
    Then the card displays document type, entity/workflow name, a status badge, a description line, and "Last edited by [name], [date/time]"

  @mobile @ui @positive
  Scenario: Tapping a card on mobile resumes the saved workflow
    Given a user is viewing the Continue Work widget on a mobile viewport
    And a document/workflow card is displayed
    When the user taps the card
    Then they are returned directly into the saved workflow
    And all previously entered data is pre-filled

  @mobile @ui @edge
  Scenario: Mobile empty state displays CTA and remains tappable
    Given a user has zero in-progress documents or workflows
    And they are viewing Workspace on a mobile viewport
    When the Continue Work widget renders
    Then the empty state displays with heading "Continue Work", message "No work to continue yet", subtext, and a "Create a new document" CTA button
    And the CTA button is tappable

  @mobile @ui @edge
  Scenario: Drag handle and feedback icons are accessible via touch on mobile
    Given a user is viewing the Continue Work widget on a mobile viewport
    When the user taps or long-presses a document card
    Then the thumbs-up and thumbs-down icons become visible and remain tappable

  @gap @negative @edge
  Scenario: Assigned user field is not displayed as it is unconfirmed for Release 1
    Given the "Assigned user" field is marked (TBC) in the UX specs and is not part of the confirmed Release 1 field set
    When a document/workflow card renders in the Continue Work widget
    Then no "Assigned user" field is displayed on the card
    And the card only shows document type, entity/workflow name, status badge, description line, and last edited by/date

  @gap @edge
  Scenario: Coverage of PRD Favourited documents requirement is unclear and needs confirmation
    Given the PRD includes a "Favourited documents" requirement
    And it is unclear whether the Continue Work widget fully satisfies that requirement
    When the widget's in-progress document set is reviewed against the PRD's Favourited documents requirement
    Then the coverage gap should be confirmed with the product owner before this AC can be considered fully verified

  @gap @edge
  Scenario: Scope of practice-wide versus per-user work surfacing is unconfirmed
    Given the Deliverable Breakdown does not confirm whether work surfacing is per-user only or also practice-wide
    When a user who belongs to a practice with in-progress work started by other users loads Workspace
    Then it is unclear whether those other users' in-progress items should appear in this user's Continue Work widget
    And this scope ambiguity should be confirmed with the product owner before this behaviour is considered verified

  @negative @edge
  Scenario: Widget handles a document with a missing or null last-edited timestamp gracefully
    Given an in-progress document exists with a missing or null last-edited timestamp
    When the Continue Work widget renders
    Then the widget does not error or crash
    And the card either falls back to a safe default display or is excluded from sort-order-dependent rendering without breaking the list

  @negative @edge
  Scenario: Widget handles server error when retrieving in-progress documents
    Given the server-side storage for in-progress documents is unavailable or returns an error
    When the Continue Work widget attempts to load
    Then the widget does not display stale or locally cached data
    And an appropriate error or fallback state is shown instead of a broken card list
