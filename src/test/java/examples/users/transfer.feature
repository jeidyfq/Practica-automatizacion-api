@ignore
Feature: Transferencia entre usuarios (reutilizable)

  Scenario: Transferir saldo del emisor al receptor
    Given url baseTxUrl
    And path '/transaction/v1/transfer'
    And header x-channel = 'WEB'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    And request
      """
      {
        "recipientId": "#(recipientId)",
        "amount": #(amount),
        "description": "#(description)"
      }
      """
    When method post
    Then status 200
    And def transactionCode = response.transactionCode
    And def transactionId   = response.id