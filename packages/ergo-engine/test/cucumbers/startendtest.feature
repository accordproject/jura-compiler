Feature: starOf and endOf with time periods test
  This describe the expected behavior for Ergo compiler when using integer literals

  Background:
    Given the Ergo contract "org.accordproject.startendtest.StartEndTest" in file "data/startendtest/logic.ergo"
    And the contract data
"""
{
  "$class": "org.accordproject.startendtest.TemplateModel"
}
"""

  Scenario: The contract should initialize
    Then the initial state should be the default state

  Scenario: The contract should return the correct response
    When it receives the request
"""
{
    "$class": "org.accordproject.startendtest.Request",
    "date": "2018-01-01T12:00:00.000+04:00"
}
"""
    Then it should respond with
"""
{
    "$class": "org.accordproject.startendtest.TestResponse",
    "startOfDay": "2018-01-01T00:00:00+04:00",
    "endOfDay": "2018-01-01T23:59:59+04:00"
}
"""

  Scenario: The contract should return the correct response
    When it receives the request
"""
{
    "$class": "org.accordproject.startendtest.Request",
    "date": "2018-01-01T12:00:00.000-11:00"
}
"""
    Then it should respond with
"""
{
    "$class": "org.accordproject.startendtest.TestResponse",
    "startOfDay": "2018-01-01T00:00:00-11:00",
    "endOfDay": "2018-01-01T23:59:59-11:00"
}
"""

