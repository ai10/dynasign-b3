dyna = @dyna
dyna.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form or e.target?.form
    $f= $ f
    dyna.valid = $(f).find('input.password').parsley('validate')
    password = $f.find('input.password').val()
    if not dyna.valid
        b3.flashWarn 'a digit, letter, and min. 6 characters.', {
            header: 'Requires: '
            single: 'dynaPass'
        }
        return

    email = dyna.emailMaybe or dyna.identity
    profile = dyna.accounts?.profile? or {}
    return Accounts.createUser {
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, {
                single: 'dynaPass'
            }
            dyna.nextStep 'password'
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            b3.flashInfo "Verification e-mail for #{email}."
            dyna.nextStep 'finished'

