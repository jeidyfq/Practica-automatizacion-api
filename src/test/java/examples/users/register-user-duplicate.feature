@ignore
Feature: Registro de usuario duplicado

  Scenario: Registrar un usuario existente
    Given url baseAuthUrl
    And path '/auth/v1/register'
    And header Content-Type = 'application/json'
    And header x-channel = 'WEB'
    And request
      """
      {
        "phone": "#(phone)",
        "fullName": "#(fullName)",
        "email": "#(email)",
        "pin": "#(pin)"
      }
      """
    When method post
    Then status 409
    And match response.code == 'AUTH_006'
    And match response.message == 'User already exists'