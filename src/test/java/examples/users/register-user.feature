@ignore
Feature: Registro de usuario (reutilizable)

  Scenario: Registrar un usuario nuevo
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
    Then status 201
    And match response.user.id == '#notnull'
    And match response.user.phone == phone
    And def userId = response.user.id