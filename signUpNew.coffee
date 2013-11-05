dyna = @dyna
dyna.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form || e.target?.form
    $f= $ f
    password = $f.find('input').val()
    console.log 'dyna', dyna
    email = dyna.emailMaybe
    profile = dyna.accounts?.profile? || {}
    console.log 'creating user', email, password, profile
    Accounts.createUser({
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, { single: 'dynaPass' }
            Session.set('dynaStep', 3)
            dyna.nextStep()
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            b3.flashInfo "A verification e-mail should be delivered to #{email} shortly."
            Meteor.call 'sendVerificationEmail', email
            Session.set('dynaStep', 5)
            dyna.nextStep()
    )

    if Session.equals('dynaStep', 1)
        dyna.emailMaybe = $f.find('input.identity').val()
        b3.flashInfo dyna.emailMaybe, {
            header: 'Please confirm e-mail:'
            single: 'dynaUser'
        }
        Session.set('dynaStep', 2)
    return dyna.nextStep()


