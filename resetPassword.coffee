dyna = @dyna
dyna.resetPassword = ( e, t ) ->
    console.log 'resetPassword', e, t
    f = t.firstNode || e.target.form
    dyna.valid = $(f).find('input.password').parsley('validate')
    if not dyna.valid
        b3.flashError 'invalid: '+e.target.value, {
            single: 'resetPassword'
        }
        return dyna.nextStep 'resetPassword'
    else
        if e.keyCode is 13
            token = Session.get('dynaToken')
            password = $(f).find('input.password').val()
            Accounts.resetPassword token, password, (error)->
                    if error?
                        b3.flashError error.reason
                        return dyna.nextStep 'forgot'
                    else
                        b3.flashSuccess ' successfully reset', {
                            header: 'Password:'
                        }
                        return dyna.nextStep 'init'
        else
            return
