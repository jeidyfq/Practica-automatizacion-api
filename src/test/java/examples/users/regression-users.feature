@regression @users
Feature: Regresión - Registro, Transferencia y Validación

  Background:
    * def headersJson = { 'Content-Type': 'application/json', 'x-channel': 'WEB' }

  Scenario: CP01 - Registrar Emisor y Receptor, recargar saldo y guardar saldos
    * print '>>> GENERANDO DATA DE PRUEBA'

    # Data única por corrida
    * def emitterPhone  = randomPhone()
    * def receiverPhone = randomPhone()
    * def emitterEmail  = randomEmail(emitterPhone)
    * def receiverEmail = randomEmail(receiverPhone)
    * assert emitterPhone != receiverPhone

    # Registro EMISOR
    * def emitter = call read('register-user.feature') {phone: '#(emitterPhone)',fullName: 'Jeidy Admin',email: '#(emitterEmail)',pin: '#(defaultPin)'}
    * assert emitter.userId != null

    # Registro RECEPTOR
    * def receiver = call read('register-user.feature') {phone: '#(receiverPhone)',fullName: 'Usuario Receptor',email: '#(receiverEmail)',pin: '#(defaultPin)'}
    * assert receiver.userId != null
    * assert emitter.userId != receiver.userId

    # Login de usuario emisor y receptor
    * def loginEmitter = call read('login-user.feature') {phone: '#(emitterPhone)', pin: '#(defaultPin)'}
    * def emitterToken = loginEmitter.token

    * def loginReceiver = call read('login-user.feature') {phone: '#(receiverPhone)', pin: '#(defaultPin)'}
    * def receiverToken = loginReceiver.token

    # Recargar saldo 1000 al Emisor y Receptor
    * def depositEmitter = call read('deposit.feature') {token:'#(emitterToken)',amount: '#(initialDeposit)'}
    * match depositEmitter.balanceAfterDeposit == initialDeposit

    # Recargar saldo al RECEPTOR
    * def depositReceiver = call read('deposit.feature') {token: '#(receiverToken)',amount: '#(initialDeposit)'}
    * match depositReceiver.balanceAfterDeposit == initialDeposit

    # Registro duplicado de usuario DEBE fallar
    * def dupResponse = call read('register-user-duplicate.feature') { phone: '#(emitterPhone)', fullName: 'Jeidy Admin', email: '#(emitterEmail)', pin: '#(defaultPin)' }
    * assert dupResponse.response.message == 'User already exists'

    # Guardar saldos actuales en variables globales
    * def data = { emitter: { id: #(emitter.userId), phone: #(emitter.phone), balance: #(depositEmitter.balanceAfterDeposit) },receiver: { id: #(receiver.userId), phone: #(receiver.phone), balance: #(depositReceiver.balanceAfterDeposit) } }
    * karate.write(data, 'global-users.json')
    # Verificación
    * def USERS = read('file:target/global-users.json')
    * assert USERS.emitter.id != null

  Scenario: CP02 - Transferencia del Emisor al Receptor con validación de saldo

    * def USERS = read('file:target/global-users.json')
    * def emitterPhone = USERS.emitter.phone
    # Login Emisor y guardar token
    * def loginEmitter = call read('login-user.feature') { phone: '#(emitterPhone)', pin: '#(defaultPin)'}
    * def tokenEmitter = loginEmitter.token

    # Saldo inicial del emisor
    * def emitterBalanceBefore = USERS.emitter.balance
    * print '>>> Saldo inicial Emisor:', emitterBalanceBefore

    # Transferencia de 450.00 con nota "Pago de Servicios"
    * def transferAmount = 450
    * def receiverId = USERS.receiver.id
    * def transferResult = call read('transfer.feature') {token: '#(tokenEmitter)',recipientId: '#(receiverId)',amount: '#(transferAmount)',description: 'Pago de Servicios'}

    # Validar la transacción
    * match transferResult.response.transactionId != null
    * match transferResult.response.referenceCode != null
    * match transferResult.response.status == 'COMPLETED'

    # Guardar código de transacción en variable global
    * def data = { REFERENCE_CODE: #(transferResult.response.referenceCode), AMOUNT: #(transferAmount)}
    * karate.write(data, 'global-transaction.json')

    # Consulta de saldo al Emisor
    * def balanceResult = call read('get-balance.feature') {token: '#(tokenEmitter)'}
    * def emitterBalanceAfter = balanceResult.currentBalance
    # Validar disminución del saldo
    * def expectedEmitterBalance = emitterBalanceBefore - transferAmount
    * match emitterBalanceAfter == expectedEmitterBalance
    * assert emitterBalanceAfter < emitterBalanceBefore

    * print '>>> Saldo Emisor después:', emitterBalanceAfter

  Scenario: CP03 - Validación de transferencia en el Receptor
    * def USERS = read('file:target/global-users.json')
    * assert USERS.receiver.id != null
    * def receiverPhone = USERS.receiver.phone

    # Login Receptor y guardar token
    * def loginReceiver = call read('login-user.feature') {phone: '#(receiverPhone)', pin: '#(defaultPin)'}
    * def loginReceiver = loginReceiver.token

    # Consulta de saldo al Receptor
    * def receiverBalance = call read('get-balance.feature') {token: '#(loginReceiver)'}
    * def receiverNewBalance = receiverBalance.currentBalance

    # Validar incremento comparando con saldo inicial
    * def receiverBalanceBefore = USERS.receiver.balance
    * def expectedReceiverBalance = receiverBalanceBefore + 450
    * match receiverNewBalance == expectedReceiverBalance
    * assert receiverNewBalance > receiverBalanceBefore

    * print '>>> Saldo Receptor inicial:', receiverBalanceBefore
    * print '>>> Saldo Receptor después:', receiverNewBalance

    # Consultar transacciones del Receptor
    Given url baseWalletUrl
    And path '/wallet/v1/transactions'
    And header Authorization = 'Bearer ' + loginReceiver
    And header x-channel = 'WEB'
    When method get
    Then status 200

    # Validar número de transacción
    * def TRANSACTION = read('file:target/global-transaction.json')
    * def code = TRANSACTION.REFERENCE_CODE
    * def amount = TRANSACTION.AMOUNT
    * print code
    * def found = karate.filter(response, function(t){ return t.referenceCode == code })
    * match found[0].referenceCode == code
    * match found[0].amount == amount
