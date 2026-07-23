Feature: Navigation

  @ui @positive
  Scenario: TC_NAV_001 - Burger menu opens and closes
    Given I am logged in and on any page
    When I click the burger menu icon
    Then the side menu should open with options: All Items, About, Logout, Reset App State
    When I click X to close
    Then the menu should close

  @ui @positive
  Scenario: TC_NAV_002 - Reset App State clears cart
    Given I have items in my cart
    When I open the burger menu and click "Reset App State"
    Then the cart badge should disappear
    And all "Add to cart" buttons should be reset

  @ui @positive
  Scenario: TC_NAV_003 - All Items menu link returns to inventory
    Given I am on a page other than inventory
    When I open the burger menu and click "All Items"
    Then I should be navigated back to the inventory page
