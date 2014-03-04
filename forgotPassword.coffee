dyna = @dyna
dyna.forgotPassword = ( e, t, opt ) ->
    console.log 'forgot password'
    f = t.firstNode || e.target.form
    $i = $(f).find('input.identity')
    dyna.valid = $i.parsley('validate')
    email = $i.val()
    if not dyna.valid
        b3.flashError 'invalid: '+email, {
            single: 'matchEmail'
        }
        return dyna.nextStep 'forgot'
    else

        if dyna.emailMaybe is email
            if Session.equals('dynaStep', 'forgot')
                b3.flashSuccess email, {
                    header: 'Matched:'
                    single: 'dynaUser'
                }
                if opt.firm is false
                    return dyna.nextStep 'forgot'
                Accounts.forgotPassword { email: dyna.emailMaybe }, (error)->
                    if error?
                        b3.flashError error.reason
                        return dyna.nextStep 'forgot'
                    else
                        b3.flashSuccess dyna.emailMaybe, {
                            header: 'Password reset link sent to: '
                        }
                        dyna.nextStep 'init'


            else
                b3.flashWarn  'input', {
                    header: dyna.emailMaybe+'- should match -'
                    single: 'dynaUser'
                }
                dyna.nextStep 'forgot'
        else
            b3.flashWarn  'input', {
                header: dyna.emailMaybe+'- should match -'
                single: 'dynaUser'
            }
            dyna.nextStep 'forgot'
