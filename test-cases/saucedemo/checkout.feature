Feature: Checkout

  @ui @smoke @positive
  Scenario: TC_CHK_001 - Proceed to step 2 with valid info
    Given I am on checkout step 1
    When I enter First Name "John", Last Name "Doe", Zip "10001"
    And I click "Continue"
    Then I should be redirected to checkout step 2
    And the URL should contain "checkout-step-two.html"

  @ui @negative
  Scenario: TC_CHK_002 - Checkout fails with empty first name
    Given I am on checkout step 1
    When I leave First Name empty and fill Last Name and Zip
    And I click "Continue"
    Then an error "Error: First Name is required" should appear

  @ui @negative
  Scenario: TC_CHK_003 - Checkout fails with empty last name
    Given I am on checkout step 1
    When I fill First Name, leave Last Name empty, fill Zip
    And I click "Continue"
    Then an error "Error: Last Name is required" should appear

  @ui @negative
  Scenario: TC_CHK_004 - Checkout fails with empty zip code
    Given I am on checkout step 1
    When I fill First Name and Last Name, leave Zip empty
    And I click "Continue"
    Then an error "Error: Postal Code is required" should appear

  @ui @positive
  Scenario: TC_CHK_005 - Cancel on step 1 returns to cart
    Given I am on checkout step 1
    When I click "Cancel"
    Then I should be returned to the cart page

  @ui @positive
  Scenario: TC_CHK_006 - Cancel on step 2 returns to inventory
    Given I am on checkout step 2 (order overview)
    When I click "Cancel"
    Then I should be returned to the inventory page

  @ui @positive
  Scenario: TC_CHK_007 - Order total is correctly calculated on step 2
    Given I have added items totalling a known price
    When I reach checkout step 2
    Then the item total and grand total should be correctly calculated and displayed

  @ui @positive
  Scenario: TC_CHK_008 - Back Home button on confirmation returns to inventory
    Given I have completed a checkout and see the confirmation page
    When I click "Back Home"
    Then I should be returned to the inventory page
    And the cart badge should not be visible

  @ui @positive
  Scenario: TC_CHK_009 - Order summary shows all price components on step 2
    Given I am on checkout step 2
    When I view the order overview
    Then I should see the item list, subtotal, tax, and total price all visible

  @ui @smoke @positive @e2e
  Scenario: TC_CHK_010 - Complete full checkout flow - finish button
    Given I am on checkout step 2 with valid items
    When I click "Finish"
    Then I should see the order confirmation screen

  @ui @smoke @positive @e2e
  Scenario: TC_CHK_011 - Order confirmation shows success message
    Given I have completed the checkout flow
    When I see the confirmation page
    Then a success header and confirmation text should be visible
