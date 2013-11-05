dyna = @dyna
dyna.signPass = ( e , t )->
    e.preventDefault()
    f = t.firstNode?.form || e.target.form
    $f = $ f
    hasError=false
    password = $f.find('input#passwordInput').val()
    if not (/\d/.test password)
        hasError = true
    if not (/\D/.test password)
        hasError = true
    if password.length < 6
        hasError = true
    if hasError
        b3.flashWarn 'requires a digit, non-digit letter, with minimum length of 6.', {header: 'Invalid Password', single: 'dynaPass' }
        return
    if Session.equals('dynaStep', 'reset')
        token = Session.get('dynaToken')
        return Accounts.resetPassword token, password, (error)->
            if error?
                b3.flashError error.reason
            else
                b3.flashSuccess 'password is now reset.'

    email = Session.get('dynaEmailMaybe')
    if Session.equals('dynaUserExisting', true)
        return dyna.login(email, password)

    profile = accounts?.defaultProfile? || {}
    console.log 'creating user', email, password, profile
    Accounts.createUser({
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, { single: 'dynaPass' }
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            b3.flashInfo "A verification e-mail should be delivered to #{email} shortly."
            Meteor.call 'sendVerificationEmail', email
            Session.set('dynaStep', 0)
    )
    false


