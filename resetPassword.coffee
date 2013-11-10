dyna = @dyna
dyna.resetPassword = ( e, t ) ->
    console.log 'resetPassword', e, t
    e.preventDefault()
    f = t.firstNode or e.target.form
    $i = $(f).find('input.password')
    dyna.valid = $i.parsley('validate')
    password = $i.val()
    if not dyna.valid
        b3.flashError 'invalid: '+e.target.value, {
            single: 'resetPassword'
        }
        return dyna.nextStep 'resetPassword'
    else
        token = Session.get('dynaToken')
        Accounts.resetPassword token, password, (error)->
            if error?
                b3.flashError error.reason
                return dyna.nextStep 'resetPassword'
            else
                b3.flashSuccess ' successfully reset', {
                    header: 'Password:'
                }
                dyna.nextStep 'finished'
                return Router.go '/'
