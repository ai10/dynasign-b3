dyna = @dyna
dyna.forgotPassword = ( e, t ) ->
    f = t.firstNode || e.target.form
    dyna.valid = $(f).find('input.identity').parsley('validate')
    if not dyna.valid
        b3.flashError 'invalid: '+e.target.value, { single: 'matchEmail' }
        return dyna.nextStep 'forgot'
    else
        if dyna.emailMaybe is e.target.value
            if Session.equals('dynaStep', 'forgot')
                b3.flashSuccess e.target.value, {
                    header: 'Matched:'
                    single: 'dynaUser'
                }
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
