Feature: Login

  @ui @smoke @positive
  Scenario: TC_LOGIN_001 - Login successfully with standard user
    Given I am on the login page
    When I enter username "standard_user" and password "secret_sauce"
    And I click the Login button
    Then I should be redirected to the inventory page
    And the product list should be visible

  @ui @negative
  Scenario: TC_LOGIN_002 - Login fails for locked out user
    Given I am on the login page
    When I enter username "locked_out_user" and password "secret_sauce"
    And I click the Login button
    Then an error message "Epic sadface: Sorry, this user has been locked out." should appear

  @ui @negative
  Scenario: TC_LOGIN_003 - Login with empty username shows error
    Given I am on the login page
    When I leave the username field empty
    And I enter password "secret_sauce"
    And I click the Login button
    Then an error message "Epic sadface: Username is required" should appear

  @ui @negative
  Scenario: TC_LOGIN_004 - Login with empty password shows error
    Given I am on the login page
    When I enter username "standard_user"
    And I leave the password field empty
    And I click the Login button
    Then an error message "Epic sadface: Password is required" should appear

  @ui @negative
  Scenario: TC_LOGIN_005 - Login with invalid credentials shows error
    Given I am on the login page
    When I enter username "invalid_user" and password "wrong_pass"
    And I click the Login button
    Then an error message "Epic sadface: Username and password do not match any user in this service" should appear

  @ui @positive
  Scenario: TC_LOGIN_006 - Error message clears when X button is clicked
    Given I am on the login page
    When I submit the form with empty credentials
    Then an error message should appear
    When I click the X button on the error message
    Then the error message should disappear

  @ui @performance
  Scenario: TC_LOGIN_007 - Login with performance glitch user succeeds (slow)
    Given I am on the login page
    When I enter username "performance_glitch_user" and password "secret_sauce"
    And I click the Login button
    Then I should eventually be redirected to the inventory page (may take up to 10s)

  @ui @smoke @positive
  Scenario: TC_LOGIN_008 - Logout successfully returns to login page
    Given I am logged in as "standard_user"
    When I open the burger menu
    And I click the Logout button
    Then I should be redirected to the login page
    And the Login button should be visible
