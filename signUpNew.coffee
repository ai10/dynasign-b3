dyna = @dyna
dyna.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form or e.target?.form
    $f= $ f
    dyna.valid = $(f).find('input.password').parsley('validate')
    dyna.valid or= $(f).find('input#password').parsley('validate')
    password = $f.find('input').val()
    if not (/\d/.test password)
        hasError = true
    if not (/\D/.test password)
        hasError = true
    if password.length < 6
        hasError = true
    if hasError
        b3.flashWarn 'requires a digit, non-digit letter, with minimum length of 6.', {header: 'Invalid Password', single: 'dynaPass' }

    if (not dyna.valid or hasError) then return

    email = dyna.emailMaybe or dyna.identity
    profile = dyna.accounts?.profile? or {}
    return Accounts.createUser({
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, { single: 'dynaPass' }
            dyna.nextStep 'password'
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            b3.flashInfo "A verification e-mail should be delivered to #{email} shortly."
            dyna.nextStep 'finished'
    )
