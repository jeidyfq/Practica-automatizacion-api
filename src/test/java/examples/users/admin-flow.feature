@regression @admin
Feature: Flujo Administrador - Validación de transacciones

  Scenario: CP04 - Flujo admin y validar transferencia
    * def USERS = read('file:target/global-users.json')
    * def emitterPhone = USERS.emitter.phone

    # Login usuario admin -> guardar token
    Given url baseAuthAdmin
    And path '/admin/v1/login'
    And header Content-Type = 'application/json'
    And header x-channel = 'WEB'
    And request
      """
      {
        "username": "admin",
        "password": "superpassword"
      }
      """
    When method post
    Then status 200
    And assert response.token != null
    And def userToken = response.token

    # validar transacción
    Given url baseAuthAdmin
    And path '/admin/v1/transactions'
    And header Authorization = 'Bearer ' + userToken
    And header x-channel = 'WEB'
    When method get
    Then status 200
