Package.describe({
    summary: "interactive e-mail/passoword sign-up / authentication using Mailgun validation API, Iron-Router, Parsley, and helpless-b3  ..."
});

Package.on_use(function (api) {
    api.use(['standard-app-packages', 'http', 'parsleyb3', 'underscore', 'jquery', 'helpless-b3'], 'client');
    api.imply('helpless-b3', 'client');
    api.use(['coffeescript', 'accounts-base', 'accounts-password', 'iron-router'], ['client', 'server']);
    api.imply(['accounts-base', 'accounts-password'],['client', 'server']);

    api.add_files('mailgun-key.coffee', 'client');

    api.add_files('dynaConfigs.coffee', ['client', 'server']);

    api.add_files([
    'parsley-defaults.coffee',
    'dynaB3.coffee',
    'dynaAlert.html',
    'dynaInline.html',
    'dynaRoutes.coffee',
    'identifyUnconfirmed.coffee',
    'confirmIdentity.coffee',
    'dynaPassword.coffee',
    'signUpNew.coffee',
    'signBack.coffee',
    'dynaAlert.coffee'
    ], ['client']);
 
    api.add_files('dynaSignMethods.coffee', ['client', 'server']);
});

