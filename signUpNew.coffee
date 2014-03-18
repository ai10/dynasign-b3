dyna = @dyna
dyna.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form or e.target?.form
    $i= $(f).find('input.password')
    dyna.valid = $i.parsley('validate')
    password = $i.val()
    if not dyna.valid
        b3.flashWarn 'a digit, letter, and min. 6 characters.', {
            header: 'Requires: '
            single: 'dynaPass'
        }
        return

    email = dyna.emailMaybe or dyna.identity
    profile = dyna.accounts?.profile? or {}
    uid = Accounts.createUser {
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
