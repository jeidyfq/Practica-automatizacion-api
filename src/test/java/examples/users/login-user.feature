@ignore
Feature: Login de usuario (reutilizable)

  Scenario: Autenticar usuario y guardar token
    Given url baseAuthUrl
    And path '/auth/v1/login'
    And header Content-Type = 'application/json'
    And header x-channel = 'WEB'
    And request
      """
      {
        "phone": "#(phone)",
        "pin": "#(pin)"
      }
      """
    When method post
    Then status 200
    And assert response.token != null
    And def token = response.token