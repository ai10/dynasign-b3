dyna = @dyna
dyna.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form || e.target?.form
    $f= $ f
    if Session.equals('dynaStep', 1)
        dyna.emailMaybe = $f.find('input.identity').val()
        b3.flashInfo dyna.emailMaybe, {
            header: 'Please confirm e-mail:'
            single: 'dynaUser'
        }
        Session.set('dynaStep', 2)
    return dyna.nextStep()


