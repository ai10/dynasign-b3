if Meteor.isClient
    dyna = @dyna = {}
    dyna.accounts = {
        loginServices: false
        logo: '/images/logo.jpeg'
        askNames: true
        askEmail: true
        dashboard: '/'
        config:
           confirmationEmail: true
    }


if Meteor.isServer

    Accounts.config(
        sendVerificationEmail: false
        forbidClientAccountCreation: false
        loginExpirationInDays: null
    )



    Accounts.emailTemplates.siteName = "UltrasoundLearn.com"

    Accounts.emailTemplates.from = "Charles J. Short <charles.short@uscmed.sc.edu>"

    Accounts.emailTemplates.verifyEmail.subject = (user)->
        email = user?.emails?[0].address?
        "Welcome to UltrasoundLearn. Please verify your e-mail: "+email

    Accounts.emailTemplates.verifyEmail.text = ( user, url)->
        "Please verify your e-mail by following the link below:\n\n"+url

    Accounts.emailTemplates.resetPassword.subject = (user) ->
        'UltrasoundLearn Password reset link.'

    Accounts.emailTemplates.resetPassword.text = (user, url) ->
        "Follow the link below to reset your password: \n\n"+url

    Accounts.onCreateUser(( options, user)->
        console.log 'onCreateUser options', options
        console.log 'oncreate', user
        if options.profile?
            user.profile = options.profile
        user
    )
    do ->
        "use strict"
        Accounts.urls.resetPassword = (token)->
            Meteor.absoluteUrl 'reset-password/'+token

        Accounts.urls.verifyEmail = (token)->
            Meteor.absoluteUrl 'verify-email/'+token

        Accounts.urls.entrollAccount = (token)->
            Meteor.absoluteUrl 'enroll-account/'+token


    Meteor.startup (->
        process.env.MAIL_URL = "smtp://postmaster%40ultrasoundlearn.mailgun.org:9-5rxdpwrja5@smtp.mailgun.org:587"
    )

