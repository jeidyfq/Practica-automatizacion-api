@ignore
Feature: Consulta de saldo (reutilizable)

  Scenario: Consultar saldo del usuario autenticado
    Given url baseWalletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + token
    And header x-channel = 'WEB'
    When method get
    Then status 200
    And match response.balance == '#number'
    And def currentBalance = response.balance