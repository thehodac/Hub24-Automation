Feature: Subnav Menu

  @ui @positive @smoke
  Scenario: Sub-nav bar visible below top bar on page load
    Given the authenticated user is on any page within NowInfinity
    When the page renders
    Then the sub-navigation bar is visible
    And it is positioned directly below the top bar
    And it is fixed to the top of the viewport

  @ui @positive
  Scenario: Sub-nav bar persists across page transitions
    Given the authenticated user is on a page with the sub-navigation bar visible
    When the user navigates between product pages causing page transitions and data loads
    Then the sub-navigation bar remains visible at all times
    And it does not disappear or flicker during the transition

  @ui @positive
  Scenario: Desktop sub-nav items render in correct order
    Given the user is on a desktop viewport and the sub-nav bar is visible
    When it renders
    Then nav items display in a single horizontal row
    And the order is Documents, Corporate Messenger, Trust Register, Super Comply, ID Verification, Individuals

  @ui @edge
  Scenario: Nav items consolidate into hamburger menu instead of wrapping below breakpoint
    Given the user is on a desktop viewport and the sub-nav bar is visible
    When the viewport width decreases below the responsive breakpoint
    Then nav items do not wrap to a second line
    And they consolidate into the hamburger menu

  @gap @edge
  Scenario: Exact pixel breakpoint for hamburger consolidation is undefined
    Given the sub-nav bar is rendering responsively per AC-02
    When the viewport width is reduced incrementally to find the consolidation threshold
    Then the exact pixel breakpoint at which items consolidate into the hamburger menu cannot be verified
    And this is a gap: the spec does not define the breakpoint value, so this test requires clarification before an exact assertion can be automated

  @ui @positive
  Scenario: Admin nav item visible for admin user
    Given the sub-nav bar renders and the user has admin permissions
    When it renders
    Then an additional Admin nav item is visible alongside the standard items

  @ui @negative
  Scenario: Admin nav item hidden for non-admin user with no reserved space
    Given the sub-nav bar renders and the user does NOT have admin permissions
    When it renders
    Then the Admin nav item is not visible
    And no placeholder space is reserved for it

  @ui @positive @smoke
  Scenario: Current section nav item shows active state
    Given the user navigates to any page within a product section such as Documents
    When the page loads
    Then the nav item for the current section is in active/selected visual state
    And all other nav items are in default state

  @ui @positive
  Scenario: Active state persists across pages within the same section
    Given the user is on a page within the Documents section with the Documents nav item active
    When the user navigates to another page within the same Documents section
    Then the Documents nav item remains in active/selected visual state

  @ui @positive
  Scenario: Clicking the active nav item opens its dropdown without changing page
    Given a nav item is in active state
    When the user clicks it
    Then the dropdown opens showing an active-expanded state
    And the page location does NOT change
    And within the dropdown the child item matching the current sub-location is shown active

  @ui @positive
  Scenario: Hovering another nav item does not close the open dropdown
    Given a dropdown is open for the active nav item and the user hovers a different nav item without clicking
    When the user hovers over the different nav item
    Then the open dropdown remains visible
    And hovering alone does NOT close or trigger a new dropdown

  @ui @positive
  Scenario: Clicking a different nav item with a dropdown swaps the open dropdown
    Given a dropdown is open for the active nav item Documents and the user clicks a different nav item with a dropdown, Corporate Messenger
    When the click is registered
    Then the Documents dropdown closes immediately
    And the Corporate Messenger dropdown opens
    And active state remains on Documents
    And Corporate Messenger shows pressed/expanded state, not active location state

  @ui @positive @smoke
  Scenario: Clicking a nav item with children opens its dropdown anchored to the item
    Given no dropdowns are open
    When the user clicks any nav item with children, such as Documents, Corporate Messenger, Trust Register, Super Comply, ID Verification, or Admin
    Then that dropdown opens anchored to the nav item

  @ui @positive @smoke
  Scenario: Clicking Individuals navigates directly without opening a dropdown
    Given no dropdowns are open
    When the user clicks Individuals
    Then no dropdown opens
    And the user navigates directly to the Individuals page

  @ui @positive
  Scenario: Clicking outside an open dropdown closes it without navigating
    Given any dropdown is open
    When the user clicks outside the panel and outside the triggering item
    Then the dropdown closes immediately
    And no navigation occurs

  @ui @positive @accessibility
  Scenario: Pressing ESC closes the open dropdown and returns focus to trigger
    Given any dropdown is open
    When the user presses ESC
    Then the dropdown closes immediately
    And focus returns to the triggering nav item

  @ui @positive
  Scenario: Opening search overlay closes an open sub-nav dropdown
    Given a sub-nav dropdown is open and the global header also offers search, account switcher, and app switcher overlays
    When the user triggers the search overlay
    Then the previously open sub-nav dropdown closes
    And the search overlay opens
    And only one overlay is open at any time across the header

  @ui @positive
  Scenario: Opening account switcher closes an open sub-nav dropdown
    Given a sub-nav dropdown is open
    When the user triggers the account switcher overlay
    Then the previously open sub-nav dropdown closes
    And the account switcher opens as the only open overlay

  @ui @positive
  Scenario: Opening app switcher closes an open sub-nav dropdown
    Given a sub-nav dropdown is open
    When the user triggers the app switcher overlay
    Then the previously open sub-nav dropdown closes
    And the app switcher opens as the only open overlay

  @ui @positive @smoke
  Scenario: Selecting a child item closes dropdown and navigates to destination
    Given an open dropdown is visible
    When the user selects a child item
    Then the dropdown closes
    And the user navigates to that item's destination

  @ui @positive @smoke
  Scenario: Documents dropdown renders all expected items
    Given the Documents dropdown has been opened
    When it renders
    Then the following items are present: Create a new document, Completed documents, E-signing, Saved documents, Bank accounts, Invoices
    And sub-type creation items are present: Standard company, Special purpose company, Public company limited by guarantee, Public company limited by shares, Foreign companies, each with a plus/add affordance
    And E-signing shows a pending-count badge

  @ui @positive
  Scenario: Clicking a plus/add affordance in Documents dropdown enters creation flow
    Given the Documents dropdown is open showing sub-type creation items with plus/add affordances
    When the user clicks a plus/add affordance for a sub-type, such as Standard company
    Then the dropdown closes
    And the user enters the corresponding document creation flow for that sub-type

  @ui @edge
  Scenario: Documents E-signing pending-count badge reflects zero pending items
    Given the Documents dropdown is open and there are zero pending e-signing items for the user
    When it renders
    Then the E-signing item either shows no badge or a badge showing zero, consistently with the product's zero-state convention

  @ui @positive @smoke
  Scenario: Corporate Messenger dropdown renders all expected items
    Given the Corporate Messenger dropdown has been opened
    When it renders
    Then the following items are present: Companies, Lodgements, Annual statements, Notification centre, Address report, Appoint an agent, Bundle edit, Reminders, Bundle agent appointment, Health centre, ASIC calendar, Other forms, Outgoing correspondence
    And Lodgements, Notification centre, and Reminders each show a count badge

  @ui @positive @smoke
  Scenario: Trust Register dropdown renders all expected items
    Given the Trust Register dropdown has been opened
    When it renders
    Then the following items are present: Trusts, Lodgements, Trust documentation, Establish a trust, Add an existing trust

  @ui @positive @smoke
  Scenario: Super Comply dropdown renders all expected items
    Given the Super Comply dropdown has been opened
    When it renders
    Then the following items are present: Funds, Funds documentation, Establish a trust, Add an existing fund, Import funds

  @ui @positive @smoke
  Scenario: ID Verification dropdown renders all expected items
    Given the ID Verification dropdown has been opened
    When it renders
    Then the following items are present: Identity verifications, Add identity verifications

  @ui @positive @smoke
  Scenario: Admin dropdown renders all expected items for admin user
    Given the Admin dropdown has been opened by an admin user
    When it renders
    Then the following items are present: Legal review, Transactions, Cache cleaner, ASIC console, Registration, Registration success

  @ui @negative
  Scenario: Corporate Messenger count badges do not render for zero counts inconsistently
    Given the Corporate Messenger dropdown is open and Lodgements, Notification centre, and Reminders all have zero outstanding counts
    When it renders
    Then the count badges are handled consistently, either hidden or showing zero, and never showing a stale non-zero count

  @accessibility @positive
  Scenario: Visible focus ring renders when tabbing to a sub-nav item
    Given the user is navigating via keyboard only
    When the user tabs to any sub-nav item
    Then a visible focus ring is rendered on that item, satisfying WCAG 2.2 Focus Appearance

  @accessibility @positive
  Scenario: Enter opens dropdown and moves focus into it
    Given the user is navigating via keyboard only and has focused a sub-nav item with a dropdown
    When the user presses Enter
    Then the dropdown opens
    And focus moves into the dropdown

  @accessibility @positive
  Scenario: Space opens dropdown and moves focus into it
    Given the user is navigating via keyboard only and has focused a sub-nav item with a dropdown
    When the user presses Space
    Then the dropdown opens
    And focus moves into the dropdown

  @accessibility @positive
  Scenario: ESC closes keyboard-opened dropdown and returns focus to trigger
    Given the user is navigating via keyboard only and a dropdown is open with focus inside it
    When the user presses ESC
    Then the dropdown closes
    And focus returns to the triggering nav item

  @accessibility @positive @smoke
  Scenario: Arrow keys move focus sequentially through open dropdown items
    Given a dropdown is open and the user uses arrow keys
    When the user presses the down arrow key repeatedly
    Then focus moves sequentially forward through the menu items
    When the user presses the up arrow key
    Then focus moves sequentially backward through the menu items

  @accessibility @positive
  Scenario: Enter on a focused dropdown item selects it and navigates
    Given a dropdown is open and a menu item is focused via arrow keys
    When the user presses Enter
    Then the focused item is selected
    And the dropdown closes
    And navigation occurs to that item's destination

  @accessibility @positive
  Scenario: Tooltip and accessible name shown for icon-only affordances on hover
    Given the sub-nav bar contains icon-only buttons/affordances such as the plus/add icons in Documents
    When the user hovers an icon-only element
    Then a tooltip is displayed
    And the element has an accessible name via aria-label

  @accessibility @positive
  Scenario: Tooltip and accessible name shown for icon-only affordances on keyboard focus
    Given the sub-nav bar contains icon-only buttons/affordances
    When the user keyboard-focuses an icon-only element
    Then a tooltip is displayed
    And the element has an accessible name via aria-label

  @accessibility @edge
  Scenario: All interactive sub-nav elements expose accessible names
    Given the sub-nav bar and its dropdowns are fully rendered including hamburger menu icon
    When an accessibility audit is run against the header region
    Then every interactive element, including icon-only buttons and the hamburger toggle, has a non-empty accessible name
    And no axe-core violations of the name-role-value rule are reported

  @ui @positive @smoke
  Scenario: Selecting a sub-nav destination updates the URL to a shareable route
    Given the user is authenticated and selects a sub-nav destination, Documents then Saved documents
    When the route changes
    Then the browser URL updates to a unique shareable route
    And the parent nav item, Documents, remains active

  @ui @positive
  Scenario: Sharing a deep link navigates directly with correct active states
    Given a user has copied a shareable sub-nav destination URL such as Documents, Saved documents
    When another authenticated user opens that URL directly
    Then the app navigates directly to the same destination
    And the correct active states are shown for the parent nav item and child item

  @negative @security
  Scenario: Direct URL access to Admin route is denied for non-admin users
    Given a user without admin permissions attempts to directly access an Admin route via URL
    When the route is resolved
    Then access is denied at the route level
    And the user is redirected appropriately
    And the Admin nav item remains hidden

  @negative @edge
  Scenario: Direct URL access to a nonexistent sub-nav child route is handled gracefully
    Given the user is authenticated and navigates directly to a deep-link URL for a sub-nav child route that does not exist
    When the route is resolved
    Then the user is shown an appropriate not-found or fallback state
    And no unhandled application error is thrown

  @mobile @positive @smoke
  Scenario: Tapping hamburger icon on mobile opens full-screen nav panel
    Given the user is on a mobile viewport and sub-nav is consolidated into the hamburger menu
    When the user taps the hamburger icon
    Then a navigation panel opens with all sub-nav items as a vertical list
    And the panel is full-screen on mobile

  @mobile @positive
  Scenario: Tapping hamburger icon on tablet opens 320px side panel
    Given the user is on a tablet viewport and sub-nav is consolidated into the hamburger menu
    When the user taps the hamburger icon
    Then a navigation panel opens with all sub-nav items as a vertical list
    And the panel renders as a 320px side panel on tablet

  @mobile @positive
  Scenario: Mobile nav panel includes Admin item for admin users
    Given the user is on a mobile viewport, has admin permissions, and taps the hamburger icon
    When the navigation panel opens
    Then the vertical list includes the Admin item in addition to the standard items

  @mobile @negative
  Scenario: Mobile nav panel excludes Admin item for non-admin users
    Given the user is on a mobile viewport, does NOT have admin permissions, and taps the hamburger icon
    When the navigation panel opens
    Then the vertical list does not include the Admin item

  @mobile @positive
  Scenario: Tapping a mobile nav item with children slides in nested view with Back button
    Given the mobile/tablet nav panel is open
    When the user taps a nav item with children, such as Documents
    Then a nested view slides in with the Documents child items matching AC-13
    And a Back button is shown

  @mobile @positive
  Scenario: Nested mobile view for Corporate Messenger matches dropdown contents
    Given the mobile/tablet nav panel is open
    When the user taps Corporate Messenger
    Then a nested view slides in with child items matching AC-14
    And a Back button is shown

  @mobile @positive
  Scenario: Nested mobile view for Trust Register matches dropdown contents
    Given the mobile/tablet nav panel is open
    When the user taps Trust Register
    Then a nested view slides in with child items matching AC-15
    And a Back button is shown

  @mobile @positive
  Scenario: Nested mobile view for Super Comply matches dropdown contents
    Given the mobile/tablet nav panel is open
    When the user taps Super Comply
    Then a nested view slides in with child items matching AC-16
    And a Back button is shown

  @mobile @positive
  Scenario: Nested mobile view for ID Verification matches dropdown contents
    Given the mobile/tablet nav panel is open
    When the user taps ID Verification
    Then a nested view slides in with child items matching AC-17
    And a Back button is shown

  @mobile @positive
  Scenario: Nested mobile view for Admin matches dropdown contents for admin user
    Given the mobile/tablet nav panel is open and the user has admin permissions
    When the user taps Admin
    Then a nested view slides in with child items matching AC-18
    And a Back button is shown

  @mobile @positive
  Scenario: Back button in nested mobile view returns to top-level list
    Given the mobile/tablet nav panel shows a nested view for Documents with a Back button
    When the user taps the Back button
    Then the panel returns to the top-level vertical list of sub-nav items

  @mobile @positive @smoke
  Scenario: Tapping Individuals on mobile navigates directly and closes panel
    Given the mobile/tablet nav panel is open
    When the user taps Individuals
    Then no nested view appears
    And the user navigates directly to the Individuals page
    And the panel closes

  @mobile @edge
  Scenario: Mobile nav panel scrolls vertically when content overflows viewport height
    Given the mobile/tablet nav panel is open and content exceeds viewport height
    When the content overflows
    Then vertical scrolling is enabled within the panel
    And all items remain reachable by scrolling

  @mobile @accessibility
  Scenario: Mobile hamburger toggle has accessible name and visible focus state
    Given the user is on a mobile viewport navigating via keyboard or assistive technology
    When the user focuses the hamburger icon
    Then a visible focus indicator is shown
    And the icon exposes an accessible name via aria-label

  @analytics @positive @smoke
  Scenario: Pendo event emitted when a top-level nav item is clicked
    Given the user interacts with a sub-nav item
    When the user clicks a top-level nav item, such as Documents
    Then a Pendo tracking event is emitted
    And the event captures the nav item clicked
    And the event captures whether navigation occurred

  @analytics @positive
  Scenario: Pendo event emitted when a dropdown child item is selected
    Given an open dropdown is visible
    When the user selects a child item, such as Saved documents under Documents
    Then a Pendo tracking event is emitted
    And the event captures the nav item clicked, Documents
    And the event captures the dropdown child item selected, Saved documents
    And the event captures that navigation occurred

  @analytics @positive
  Scenario: Pendo event emitted when clicking active nav item only opens dropdown without navigation
    Given a nav item is in active state and the user clicks it to open the dropdown without navigating
    When the click is registered
    Then a Pendo tracking event is emitted
    And the event captures the nav item clicked
    And the event captures that no navigation occurred

  @analytics @edge
  Scenario: Pendo event emitted when a plus/add affordance is used inside a dropdown
    Given the Documents dropdown is open showing sub-type creation items with plus/add affordances
    When the user clicks the plus/add affordance for Standard company
    Then a Pendo tracking event is emitted
    And the event captures the nav item clicked, Documents
    And the event captures the dropdown child item selected, Standard company add affordance
    And the event captures that navigation occurred into the creation flow

  @negative @edge
  Scenario: Rapid repeated clicks on the same nav item do not toggle inconsistent dropdown states
    Given no dropdowns are open
    When the user rapidly double-clicks a nav item with children
    Then the dropdown reaches a single stable open or closed state
    And no duplicate or stuck dropdown panels are rendered

  @negative @edge
  Scenario: Clicking a nav item with children while another item's dropdown is animating closed does not open two dropdowns
    Given a dropdown is open and mid-close-transition
    When the user clicks a different nav item with children before the close transition completes
    Then only one dropdown is open once transitions settle
    And no visual overlap of two open dropdowns occurs

  @edge @ui
  Scenario: Sub-nav bar remains fixed to top during long page scroll
    Given the user is on a product page whose content is taller than the viewport
    When the user scrolls the page content
    Then the sub-navigation bar remains fixed at the top of the viewport
    And it does not scroll out of view

  @negative @accessibility
  Scenario: Screen reader announces dropdown expanded/collapsed state
    Given the user is using a screen reader and focuses a nav item with a dropdown
    When the user activates the item to open the dropdown
    Then the screen reader announces the expanded state via aria-expanded=true
    When the user closes the dropdown
    Then the screen reader announces the collapsed state via aria-expanded=false
