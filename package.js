Package.describe({
    summary: "interactive e-mail/passoword sign-up / authentication using Mailgun validation API, Iron-Router, Parsley, and helpless-b3  ..."
});

Package.on_use(function (api) {
    api.use(['standard-app-packages', 'http', 'parsleyb3', 'helpless-b3', 'underscore', 'jquery'], 'client');
    api.use(['coffeescript', 'accounts-base', 'accounts-password', 'iron-router'], ['client', 'server']);
    api.imply(['accounts-base', 'accounts-password'],['client', 'server']);

    api.add_files('dynaConfigs.coffee', ['client', 'server']);

    api.add_files([
    'parsley-defaults.coffee',
    'dynaSign.html',
    'dynaSign.coffee'
    ], ['client']);
    
    api.add_files('accounts-b3.coffee', ['client', 'server']);

    if (typeof api.export !== 'undefined'){
        api.export([
        'b3'
        ], 'client');
    }


});

