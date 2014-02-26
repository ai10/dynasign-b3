if Meteor.isClient
    dyna = @dyna = {}
    dyna.isInline = true
    dyna.requestProfileCompletion = true

if Meteor.isServer

    Accounts.config(
        sendVerificationEmail: true
        forbidClientAccountCreation: false
        loginExpirationInDays: 30
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

