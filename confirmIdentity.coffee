dyna = @dyna
dyna.confirmIdentity = ( e, t ) ->
    #get form whether a click or a keyup.
    f = t.firstNode || e.target.form
    #should user carriage return after auto don't act on empty.
    if e.keyCode is 13
        if e.target.value.length < 2 then return
    #validate input with parsley
    dyna.valid = $(f).find('input.identity').parsley('validate')
    if not dyna.valid
        b3.flashError 'invalid: '+e.target.value, {
            single: 'matchEmail'
        }
        return dyna.nextStep 'confirmation'
    else
        if dyna.emailMaybe is e.target.value
            if Session.equals('dynaStep', 'confirmation')
                b3.flashSuccess e.target.value, {
                    header: 'Matched:'
                    single: 'dynaUser'
                }
                b3.flashInfo 'Please enter a password.', {
                    header: ""
                    single: 'dynaPass'
                }
                return dyna.nextStep 'signUpNew'
        else
            b3.flashWarn  'input', {
                header: dyna.emailMaybe+'- should match -'
                single: 'dynaUser'
            }
            return dyna.nextStep 'confirmation'
