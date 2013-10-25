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

