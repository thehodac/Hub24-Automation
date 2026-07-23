Feature: Cart

  @ui @smoke @positive
  Scenario: TC_CART_001 - Cart page displays added items correctly
    Given I have added "Sauce Labs Backpack" to the cart
    When I navigate to the cart page
    Then I should see "Sauce Labs Backpack" listed in the cart
    And the item name, description, and price should be correct

  @ui @positive
  Scenario: TC_CART_002 - Remove item from cart page
    Given I have "Sauce Labs Backpack" in the cart
    When I click "Remove" on the cart page
    Then the item should be removed from the cart
    And the cart badge should not be visible

  @ui @positive
  Scenario: TC_CART_003 - Continue Shopping button returns to inventory
    Given I am on the cart page
    When I click "Continue Shopping"
    Then I should be returned to the inventory page

  @ui @smoke @positive
  Scenario: TC_CART_004 - Checkout button navigates to checkout step 1
    Given I have at least one item in the cart
    When I click "Checkout"
    Then I should be navigated to the checkout information page
    And the URL should contain "checkout-step-one.html"

  @ui @positive
  Scenario: TC_CART_005 - Empty cart shows no items
    Given I am logged in as "standard_user" and have not added any items
    When I navigate to the cart page
    Then the cart should be empty with no items listed

  @ui @positive
  Scenario: TC_CART_006 - Cart persists after page reload
    Given I have added "Sauce Labs Backpack" to the cart
    When I reload the page
    Then the cart badge should still show "1"
    And the item should still be in the cart
