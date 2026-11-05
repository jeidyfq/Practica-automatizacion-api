@ignore
Feature: Recarga de saldo (reutilizable)

  Scenario: Recargar saldo de un usuario
    Given url baseWalletUrl
    And path '/wallet/v1/deposit'
    And header Content-Type = 'application/json'
    And header x-channel = 'WEB'
    And header Authorization = 'Bearer ' + token
    And request { amount: '#(amount)' }
    When method post
    Then status 200
    And assert response.newBalance >= amount
    And def balanceAfterDeposit = response.newBalance