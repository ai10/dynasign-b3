dyna = @dyna
dyna.forgotPassword = ( e, t ) ->
    f = t.firstNode || e.target.form
    dyna.valid = $(f).find('input#identity').parsley('validate')
    dyna.valid = dyna.valid || $(f).find('input.identity').parsley('validate')
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
        else
            b3.flashWarn  'input', {
                header: dyna.emailMaybe+'- should match -'
                single: 'dynaUser'
            }
        if e.keyCode is 13
            Accounts.forgotPassword dyna.emailMaybe, (error)->
                if error?
                    b3.flashError error.reason
                else
                    b3.flashSuccess dyna.emailMaybe, {
                        header: 'Password reset link sent to: '
                    }
                    dyna.nextStep 'init'

        return dyna.nextStep 'confirmation'
