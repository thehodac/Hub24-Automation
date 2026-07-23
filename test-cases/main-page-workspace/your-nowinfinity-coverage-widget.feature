Feature: Your NowInfinity Coverage Widget

  @ui @positive @smoke
  Scenario: Donut chart renders with coverage percentage
    Given an authorised user loads the Workspace page
    When the Your NowInfinity Coverage widget renders
    Then a donut/ring chart displays a percentage value
    And the label "of its capability in active use" appears beneath the percentage

  @functional @edge
  Scenario: Coverage percentage is a rounded whole number
    Given the coverage percentage is calculated
    When it is displayed
    Then it is shown as a whole number rounded to the nearest integer with no decimal places

  @ui @positive
  Scenario: Chart segments render with correct colour-coded classifications
    Given the chart renders with product segment data
    When the donut chart displays
    Then each product category shows as a colour-coded arc: Strong usage (darkest blue), Growing usage (medium blue), Explore next (lighter blue), Recommended (lightest blue/outline)

  @ui @edge
  Scenario: Single active category still renders full chart
    Given only one product category is active
    When the donut chart renders
    Then the active segment is shown
    And the remaining inactive arc is shown in neutral grey

  @ui @positive
  Scenario: Legend displays all four classification entries
    Given the widget renders
    When the legend displays
    Then it shows four entries: Strong usage, Growing usage, Explore next, and Recommended, each with a product name

  @ui @positive
  Scenario: Clicking a legend item highlights the corresponding chart segment
    Given the legend is rendered
    When the user clicks a legend item
    Then the corresponding segment in the donut chart is visually highlighted

  @functional
  Scenario: Clicking a legend product navigates to the relevant product area
    Given a legend item's associated product is shown
    When the user clicks it
    Then the user is navigated to the relevant product area or discovery flow for that product

  @functional
  Scenario: Firm switch refreshes coverage data
    Given the user switches firms via the account selector
    When the switch completes
    Then the widget refreshes to display coverage data for the newly selected firm

  @edge
  Scenario: Zero usage firm shows 0% and neutral ring
    Given a firm has zero usage across all products
    When the widget loads
    Then the percentage displays "0%"
    And the donut chart renders as a full neutral-grey ring with an appropriate empty state message

  @functional
  Scenario: Explore next navigation avoids broken or unauthorised pages
    Given a product is classified as "Explore next"
    When the user clicks the legend item
    Then the user is navigated to information or an onboarding flow for that product, not a broken or unauthorised page

  @negative @edge
  Scenario: Recommended product without access leads to informational page
    Given a product is classified as "Recommended"
    And the user does not have access to it
    When the user clicks the legend item
    Then navigation leads to an informational page rather than an error or access-denied screen

  @ui @edge
  Scenario: Skeleton loader shown while coverage data is fetching
    Given the widget is fetching coverage data
    When the page is loading
    Then a skeleton loader or animated placeholder ring is displayed in place of the chart

  @negative
  Scenario: Inline error message shown when coverage data fetch fails
    Given the data fetch fails or times out
    When the failure occurs
    Then an inline error message "Unable to load coverage data. Please refresh." renders
    And other Workspace widgets are not affected

  @functional @gap
  Scenario: Role-based visibility for non-Partner/Admin users is undefined
    Given a standard user who is not Partner or Admin loads the Workspace
    When the Coverage widget would render
    Then the role-based visibility rule (read-only view vs hidden) must be explicitly defined and consistently applied
    And this is flagged as a design coverage gap pending Product/UX resolution

  @mobile @ui
  Scenario: Chart scales proportionally on narrow viewport
    Given the widget renders at a reduced viewport width
    When the donut chart displays
    Then it scales proportionally without being cropped or overflowing the widget boundary

  @mobile @ui
  Scenario: Legend reflows beneath the chart on narrow viewport
    Given the legend cannot fit beside the chart on a narrow viewport
    When the widget renders
    Then the legend displays beneath the chart in a vertical list layout

  @accessibility
  Scenario: Donut chart has an accessible text alternative
    Given a screen reader is active
    When the donut chart renders
    Then it is accompanied by an aria-label or visually hidden description conveying the percentage and product breakdown

  @accessibility
  Scenario: Legend items are keyboard focusable
    Given a keyboard user navigates the widget
    When the user tabs through the legend
    Then each legend item is focusable via Tab key with a visible focus indicator

  @accessibility
  Scenario: Chart segments have non-colour visual distinction
    Given chart segments are differentiated by colour
    When the chart renders
    Then a non-colour visual distinction such as pattern, label, or tooltip is also provided to meet WCAG 1.4.1

  @analytics
  Scenario: Pendo impression event fires with coverage data
    Given the Coverage widget renders with data
    When the render completes
    Then a Pendo impression event is fired recording the firm's coverage percentage and product classifications

  @analytics
  Scenario: Pendo event fires on legend item click
    Given a legend item links to a product
    When the user clicks it
    Then a Pendo event is fired capturing the product name and classification (Explore next / Recommended)

  @gap
  Scenario: Coverage calculation methodology is undefined
    Given the widget displays a coverage percentage such as "58%"
    When reviewing PRD and UX specification
    Then no definition exists for how capability is measured or classification thresholds are determined
    And this is flagged as a design coverage gap pending Product/UX resolution
