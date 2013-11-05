dyna = @dyna

console.log 'dyna', dyna

Template.b3Alert.events
    'keyup input.identity': (e, t) ->
        dyna.identity = e.target.value
        alert = @_id
        initial_cb = (e, t) =>
            console.log 'initial cb fired', alert
            console.log 'dyna', dyna
            b3.Alert::remove alert
            return dyna.identifyUnconfirmed e, t, alert

        confirm_cb = ( e, t ) ->
            console.log 'confirm cb fired', alert
            console.log 'dyna', dyna
            b3.Alert::remove alert
            return dyna.confirmIdentity e, t, alert

        cb = initial_cb
        if dyna.confirmation is true then cb = confirm_cb

        dyna.inputThrottle e, t, cb

    'keyup input.password': (e, t) ->
        dyna.password = e.target.value
        alert = @_id
        back_cb = dyna.passBack e, t, =>
            console.log 'passBack cb fired'
            b3.Alert::remove alert
            return
        new_cb = dyna.passNew e, t, =>
            console.log 'passNew cn fired'
            b3.Alert::remove alert

        dyna.inputThrottle e, t, cb

    'keydown input': (e, t) ->
        if e.keyCode is 13
            e.preventDefault()
            return
    'click button.enterPassword': ( e, t ) ->
        step = Session.get 'dynaStep'
        console.log 'button at step;', step
        if step is 3
            return dyna.signUpNew e, t

        if step is 4
            return dyna.signBack e, t

    'click button.identity': ( e, t) ->
        console.log 'click identity', e, t
        i = t.find('input')
        dyna.identity = $(i).val()
        alert = @_id
        initial_cb = (e, t) =>
            console.log 'initial cb fired', alert
            console.log 'dyna', dyna
            b3.Alert::remove alert
            return dyna.identifyUnconfirmed e, t, alert

        confirm_cb = ( e, t ) ->
            console.log 'confirm cb fired', alert
            console.log 'dyna', dyna
            b3.Alert::remove alert
            return dyna.confirmIdentity e, t, alert

        cb = initial_cb
        if dyna.confirmation is true then cb = confirm_cb

        dyna.inputThrottle e, t, cb

    'click button.changeUser': ( e, t ) ->
        dyna.reset()
        Session.set 'dynaStep', 1
        dyna.nextStep()




@b3.promptIdentity = @b3.Alert::curry {
    dialog: true
    region: 'middleCenter'
    type: 'info'
    block: 'alert-block'
    inputType: 'email'
    selectClass: 'identity'
    header: 'Identification'
    label: 'Please enter your e-mail'
    placeholder: 'e-mail ...'
    icon: 'glyphicon glyphicon-envelope'
}

@b3.promptPassword = @b3.Alert::curry {
    dialog: true
    confirmation: true
    label: 'Minimum 6 characters.'
    type: 'info'
    buttonText: ""
    region: 'middleCenter'
    block: 'alert-block'
    inputType: 'password'
    selectClass: 'enterPassword'
    header: 'Enter Password'
    icon: "glyphicon glyphicon-log-in"
}
@b3.confirmIdentity = @b3.Alert::curry {
    dialog: true
    confirmation: true
    showAltButton: true
    region: 'middleCenter'
    altButtonText: " change e-mail."
    altSelectClass: "changeUser"
    type: 'info'
    selectClass: 'identity'
    block: 'alert-block'
    inputType: 'text'
    header: 'New?'
    icon: 'glyphicon glyphicon-envelope'
}

dyna.nextStep = =>
    step = Session.get 'dynaStep'
    console.log 'step', step
    dyna.resetThrottle()
    switch Session.get 'dynaStep'
        when 0,1 #authorization begins; existing user jump to 4.
            if not dyna.valid
                @b3.promptIdentity 'Invalid', { value: dyna.identity, header: dyna.userEmail, type: 'warning' }
            else
                @b3.promptIdentity()
            return
        when 2 #confirm identity go to 3.
            dyna.confirmation = true
            if not dyna.valid
                @b3.confirmIdentity 'Invalid', { value: dyna.identity, type: 'danger' }
            else
                @b3.confirmIdentity 'Please confirm:', { value: dyna.identity, label: dyna.emailMaybe }
            return
        when 3, 4 #enter password
            if not dyna.valid
                @b3.promptPassword 'Invalid', { type: 'warning' }
            else
                @b3.promptPassword()
            return
        else
            return

dyna.reset = =>
    Session.set 'dynaStep', 0
    dyna.userEmail = 'invalid e-mail'
    dyna.userExisting = false
    dyna.confirmation = false
    dyna.valid = true
    @b3.Alert::clearAll()
    return true

dyna.passwordReset = ->
    @b3.confirmIdentity 'Confirm e-mail for password reset', { header: dyna.emailMaybe, type: 'info', selectClass: 'forgotPassword' }


Template.dynaSignButton.created = ->
    dyna.reset()

Template.dynaSignButton.button = ->
    step = Session.get 'dynaStep'
    console.log 'dynaStep', step
    switch step
        when 0, 1
            return {
                text: 'Authenticate'
                style: 'btn-primary'
                icon: 'glyphicon-log-in'
            }
        when 2 #confirm step
            return {
                text: dyna.emailMaybe
                style: 'btn-danger'
                icon: 'glyphicon-remove-sign'
            }
        when 3 #signUpNew step
               return {
                    text: dyna.emailMaybe
                    style: 'btn-danger'
                    icon: 'glyphicon-remove-sign'
                }
        when 4 #signBack step
            if dyna.userExisting
                return {
                    text: 'Forgot Password'
                    style: 'btn-default'
                    icon: 'glyphicon-question-sign'
                }
        else # logged in? or somethings wrong.
            return {
                text: "logout: #{dyna.emailMaybe}"
                style: 'btn-danger btn-xs'
                icon: 'glyphicon-log-out'
            }

Template.dynaSignButton.events
    'click button': ->
        console.log 'dynaSignClick'
        switch Session.get 'dynaStep'
            when 0
                dyna.nextStep()
            when 1, 2, 3
                dyna.reset()
                Session.set 'dynaStep', 1
                dyna.nextStep()
            when 4
                dyna.passwordReset()
                #send reset password link
            when 5
                dyna.logout()
            else
                console.log 'error'
