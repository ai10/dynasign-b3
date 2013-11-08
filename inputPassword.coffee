dyna = @dyna
dyna.inputPassword = (e, t)->
    e.preventDefault()
    if (e.target.id isnt 'passwordInput') then return
    if e.keyCode is 13
        return @signPass(e, t)
    f = t.firstNode || e.target.f
    valid = $(f).find("input#passwordInput").parsley('validate')
    if valid
        Session.set('dynaPasswordTooltip', 'password valid')
        if Session.equals('dynaUserExisting', true)
            email = Session.get 'dynaEmailMaybe'
            return @dynaLogin( email, e.target.value )
    else
        msg = "Password: "
        if e.target.value.length < 6
            msg += '- min. 6 characters'
        if not /\d/.test e.target.value
            msg += '- min. 1 number '
        if not /\D/.test e.target.value
            msg += '- min. 1 letter'
        Session.set('dynaPasswordTooltip', msg)
    false


