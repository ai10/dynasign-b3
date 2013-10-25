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
    console.log 'onCreate', arguments
    if options.profile?
        user.profile = options.profile
    return user
)

Meteor.startup (->
    process.env.MAIL_URL = "smtp://postmaster%40ultrasoundlearn.mailgun.org:9-5rxdpwrja5@smtp.mailgun.org:587"
    console.log process.env.MAIL_URL
)

