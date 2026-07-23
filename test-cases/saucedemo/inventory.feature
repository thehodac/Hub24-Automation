Feature: Inventory / Product List

  @ui @smoke @positive
  Scenario: TC_INV_001 - Inventory page displays 6 products
    Given I am logged in as "standard_user"
    When I am on the inventory page
    Then I should see exactly 6 product items

  @ui @positive
  Scenario: TC_INV_002 - Sort products A to Z
    Given I am on the inventory page
    When I select sort option "Name (A to Z)"
    Then the product names should be sorted in ascending alphabetical order

  @ui @positive
  Scenario: TC_INV_003 - Sort products Z to A
    Given I am on the inventory page
    When I select sort option "Name (Z to A)"
    Then the product names should be sorted in descending alphabetical order

  @ui @positive
  Scenario: TC_INV_004 - Sort products by price low to high
    Given I am on the inventory page
    When I select sort option "Price (low to high)"
    Then the product prices should be sorted in ascending order

  @ui @positive
  Scenario: TC_INV_005 - Sort products by price high to low
    Given I am on the inventory page
    When I select sort option "Price (high to low)"
    Then the product prices should be sorted in descending order

  @ui @smoke @positive
  Scenario: TC_INV_006 - Add item to cart shows badge count
    Given I am on the inventory page
    When I click "Add to cart" on "Sauce Labs Backpack"
    Then the cart icon badge should show "1"

  @ui @positive
  Scenario: TC_INV_007 - Add multiple items to cart updates badge
    Given I am on the inventory page
    When I add "Sauce Labs Backpack" and "Sauce Labs Bike Light" to cart
    Then the cart icon badge should show "2"

  @ui @positive
  Scenario: TC_INV_008 - Remove item from inventory page hides badge
    Given I have added "Sauce Labs Backpack" to the cart
    When I click "Remove" on the same product
    Then the cart icon badge should not be visible

  @ui @positive
  Scenario: TC_INV_009 - Click product name navigates to detail page
    Given I am on the inventory page
    When I click on the name "Sauce Labs Backpack"
    Then I should be navigated to the product detail page
    And the URL should contain "inventory-item.html"

  @ui @positive
  Scenario: TC_INV_010 - Click cart icon navigates to cart page
    Given I am on the inventory page
    When I click the cart icon
    Then I should be navigated to the cart page
    And the URL should contain "cart.html"
