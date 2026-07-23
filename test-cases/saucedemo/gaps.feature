Feature: Gaps (documented risks - not automated)

  @ui @gap
  Scenario: TC_GAP_001 - problem_user broken images / form bugs (spec gap - not fully specified)
    Given I am logged in as "problem_user"
    When I browse the inventory and checkout
    Then broken images and form bugs are expected but exact acceptance criteria are NOT defined in the spec

  @ui @gap
  Scenario: TC_GAP_002 - error_user action-specific error behaviours (spec gap)
    Given I am logged in as "error_user"
    When I perform add-to-cart / checkout actions
    Then specific error behaviours occur but are NOT defined in the spec

  @visual @gap
  Scenario: TC_GAP_003 - visual_user visual differences need screenshot comparison (Chromatic)
    Given I am logged in as "visual_user"
    When I view the inventory page
    Then visual differences require a screenshot/visual regression check (Chromatic), not a functional assertion
