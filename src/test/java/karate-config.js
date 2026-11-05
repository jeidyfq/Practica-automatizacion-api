function fn() {
    var env = karate.env; // get system property 'karate.env'
    var config = {
        baseAuthUrl: 'http://134.209.211.10:4001',
        baseWalletUrl: 'http://134.209.211.10:4002',
        baseTxUrl: 'http://134.209.211.10:4003',
        baseAuthAdmin: 'http://134.209.211.10:4004',
        defaultPin: '123456',
        initialDeposit: 1000,
        env: env,
        myVarName: 'someValue',
    };

    // ---- Celular aleatorio (9 dígitos, inicia con 9) ----
    config.randomPhone = function () {
        var phone = '9';
        for (var i = 0; i < 8; i++) {
            phone += Math.floor(Math.random() * 10);
        }
        return phone;
    };

    config.randomEmail = function (phone) {
        return 'qa.' + phone + '@test.com';
    };

    if (env == 'dev') {
        // customize
        // e.g. config.foo = 'bar';
    } else if (env == 'e2e') {
        // customize
    }
    return config;
}