Feature: What's New Widget

  @ui @positive @smoke
  Scenario: Widget renders card with all required elements
    Given a user loads Workspace
    When the What's New widget renders
    Then a card displays with a badge (Enhancement, New Feature, Announcement, or Coming Soon)
    And the card displays a headline, body copy, a CTA link with an arrow icon, and a supporting visual

  @ui @positive
  Scenario: Each badge type renders correctly on a card
    Given a user loads Workspace
    When a card renders with a given update type
    Then the badge label matches one of Enhancement, New Feature, Announcement, or Coming Soon
    And the badge is visually distinct from the headline and body copy

  @ui @positive @smoke
  Scenario: Carousel with dot indicators displays for multiple updates
    Given more than one update is available
    When the widget renders
    Then a carousel displays with dot indicators
    And the dot indicators allow navigation between multiple update cards

  @ui @positive
  Scenario: User navigates carousel via dot indicators
    Given the widget has rendered a carousel with multiple cards
    When the user clicks a dot indicator for a different card
    Then the carousel transitions to the corresponding card
    And the active dot indicator updates to reflect the currently displayed card

  @ui @edge
  Scenario: Single update available suppresses carousel controls
    Given only one update is available
    When the widget renders
    Then no carousel or dot indicators are displayed
    And the single card displays without navigation controls

  @ui @positive
  Scenario: Date-marker variant displays calendar-style date block
    Given a specific update has an associated date
    And the date-marker variant is enabled
    When that card renders
    Then a calendar-style date block (e.g. "Jul 22 Wed") displays adjacent to the headline

  @ui @negative @edge
  Scenario: Card without date-marker variant enabled omits date block
    Given a specific update has an associated date
    And the date-marker variant is not enabled
    When that card renders
    Then no calendar-style date block displays adjacent to the headline

  @ui @edge
  Scenario: Card with no associated date renders without date block
    Given a specific update has no associated date
    And the date-marker variant is enabled
    When that card renders
    Then no calendar-style date block displays
    And the card layout remains visually consistent with dated cards

  @ui @positive
  Scenario: CTA label and destination adapt per update
    Given a card is displayed
    When the user views the card's CTA
    Then the CTA label (e.g. "Learn more," "Explore Feature," "See What's Changing," "Take a Tour") matches the specific update being communicated
    And the CTA destination link corresponds to that same update

  @ui @positive @smoke
  Scenario: Clicking CTA navigates to the correct destination
    Given a card is displayed
    When the user clicks its CTA
    Then the user is navigated to the destination associated with that specific update
    And the navigation occurs without disrupting the surrounding Workspace layout

  @ui @positive
  Scenario: Release 1 example cards render as specified
    Given Release 1 content is populating the widget
    When example cards render
    Then cards may include "Introducing the new app header," "Introducing the workspace," "Coming soon in Release 2," and "Get your tickets to Ignite"
    And each example card displays its own badge, headline, body copy, and CTA

  @ui @negative
  Scenario: No filter, sort, or export controls present
    Given the widget has rendered
    When viewed
    Then no filter controls are present
    And no sort controls are present
    And no export controls are present

  @ui @negative
  Scenario: No feedback (thumbs up/down) controls present
    Given the widget has rendered
    When viewed
    Then no thumbs up control is present
    And no thumbs down control is present
    And no other feedback-collection affordance is present on the widget

  @mobile @ui @positive
  Scenario: Widget and carousel render responsively on mobile viewport
    Given a user loads Workspace on a mobile viewport
    When the What's New widget renders
    Then the card content (badge, headline, body copy, CTA, visual) remains fully visible without horizontal overflow
    And the carousel dot indicators remain visible and operable via touch

  @mobile @positive
  Scenario: Swipe gesture navigates carousel on mobile
    Given the widget has rendered a carousel with multiple cards on a mobile viewport
    When the user swipes the card horizontally
    Then the carousel transitions to the adjacent card
    And the active dot indicator updates accordingly

  @analytics @gap
  Scenario: CTA click emits analytics tracking event
    Given a card is displayed
    When the user clicks its CTA
    Then an analytics event is captured that identifies the specific update and CTA clicked
    And no analytics tracking mechanism is documented in the spec, so this scenario cannot be fully verified without further design input

  @accessibility @gap
  Scenario: Widget is keyboard and screen-reader accessible
    Given a user navigates Workspace using only a keyboard and/or screen reader
    When the What's New widget receives focus
    Then the badge, headline, body copy, CTA, and visual are announced with appropriate semantics
    And carousel dot indicators are reachable and operable via keyboard
    And no WCAG/ARIA requirements are documented in the spec, so expected behavior is undefined pending design input

  @accessibility @gap @edge
  Scenario: Role-based visibility of widget content is unverifiable
    Given users with different roles or permission levels load Workspace
    When the What's New widget renders
    Then the widget content shown should reflect any role-based visibility rules
    And no role-based visibility rules are documented in the spec, so this scenario cannot be verified without further design input

  @edge @gap
  Scenario: Widget behavior when no updates are available is undefined
    Given zero updates are available to populate the widget
    When the widget attempts to render
    Then the widget should display a defined empty state
    And no empty-state design or content is documented in the spec, so expected behavior is undefined pending design input

  @edge @gap
  Scenario: Widget behavior during content load is undefined
    Given the widget is fetching update content
    When the content has not yet loaded
    Then the widget should display a defined loading state
    And no loading-state design is documented in the spec, so expected behavior is undefined pending design input

  @edge @negative @gap
  Scenario: Widget behavior on content fetch failure is undefined
    Given the widget attempts to load update content
    When the content fails to load due to an error
    Then the widget should display a defined error state
    And no error-state design or messaging is documented in the spec, so expected behavior is undefined pending design input

  @gap @edge
  Scenario: "View all" or archive navigation pattern is undefined
    Given a user wants to view updates beyond those shown in the widget
    When the user looks for a "view all" or archive entry point
    Then a defined navigation pattern to a full update history should exist
    And no "view all"/archive navigation pattern is documented in the spec, so this scenario cannot be verified without further design input

  @gap @edge
  Scenario: Content authoring/publishing mechanism is undefined
    Given a content author needs to create, schedule, or publish a What's New card
    When they attempt to author new widget content
    Then a defined CMS or authoring mechanism should exist to create/schedule/publish cards
    And no content authoring/CMS mechanism is documented anywhere in the spec, so this scenario cannot be verified without further design input

  @ui @negative @edge
  Scenario: Hover state on card and CTA is undefined
    Given a card is displayed
    When the user hovers over the card or its CTA
    Then a defined hover state should be visually indicated
    And no hover-state design is documented in the spec, so expected behavior is undefined pending design input
