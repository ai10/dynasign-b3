dyna = @dyna
dyna.confirmIdentity = ( e, t ) ->
    console.log 'dynaConfirmIdentity'
    f = t.firstNode || e.target.form
    dyna.valid = $(f).find('input#identity').parsley('validate')
    dyna.valid = dyna.valid || $(f).find('input.identity').parsley('validate')
    if not dyna.valid
        b3.flashError 'invalid: '+e.target.value
        return dyna.nextStep false
    else
        if dyna.emailMaybe is e.target.value
            if Session.equals('dynaStep', 2)
                b3.flashSuccess e.target.value, {
                    header: 'Matched:'
                    single: 'dynaUser'
                }
                b3.flashInfo 'Please enter a password.', {
                    header: ""
                    single: 'dynaPass'
                }
                Session.set('dynaStep', 3)
                return dyna.nextStep true
        else
            b3.flashWarn e.target.value, {
                header: dyna.emailMaybe+'- should match -'
                single: 'dynaUser'
            }
            return dyna.nextStep false
