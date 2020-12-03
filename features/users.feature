Feature: Users
  Background:
    Given I am logged in as an activated user

  # @javascript
  Scenario: Users List
    When I go to the list of users
    Then I should see "Users"
    And I should see "All users"
