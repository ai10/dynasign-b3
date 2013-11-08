dyna = @dyna
Template.b3Alert.events
    'keyup input.identity': (e, t) ->
        dyna.identity = e.target.value
        alert = @_id
        initial_cb = (e, t) =>
            return dyna.identifyUnconfirmed e, t, alert

        confirm_cb = ( e, t ) =>
            return dyna.confirmIdentity e, t, alert

        forgot_cb = ( e, t ) =>
            return dyna.forgotPassword e, t, alert

        switch Session.get('dynaStep')
            when 'confirmation' then cb = confirm_cb
            when 'forgot' then cb = forgot_cb
            else
                cb = initial_cb

        dyna.inputThrottle e, t, cb

    'keyup input.password': (e, t) ->
        dyna.password = e.target.value
        alert = @_id

        back_cb = ( e, t ) =>
            dyna.signBack e, t, alert
            return

        upNew_cb = ( e, t ) =>
            dyna.signUpNew e, t, alert
            return

        cb = back_cb
        if Session.equals('dynaStep', 'signUpNew')
            cb = upNew_cb
            unless e.keyCode is 13 then return

        dyna.inputThrottle e, t, cb

    'keydown input': (e, t) ->
        if e.keyCode is 13
            e.preventDefault()
            return
    'click button.password': ( e, t ) ->
        step = Session.get 'dynaStep'
        if step is 'signUpNew'
            return dyna.signUpNew e, t

        if step is 'signBack'
            return dyna.signBack e, t

    'click button.identity': ( e, t) ->
        i = t.find('input')
        dyna.identity = $(i).val()
        alert = @_id
        initial_cb = (e, t) =>
            return dyna.identifyUnconfirmed e, t, alert

        confirm_cb = ( e, t ) ->
            return dyna.confirmIdentity e, t, alert

        cb = initial_cb
        if dyna.confirmation is true then cb = confirm_cb
        dyna.inputThrottle e, t, cb

    'click button.changeUser': ( e, t ) ->
        dyna.reset()
        dyna.nextStep 'identify'

@b3.promptIdentity = @b3.Alert::curry {
    dialog: true
    confirmation: true
    buttonText: ""
    region: 'middleCenter'
    type: 'info'
    block: 'alert-block'
    inputType: 'email'
    selectClass: 'identity'
    header: 'Email'
    label: 'Please enter your e-mail.'
    placeholder: 'e-mail ...'
    icon: 'glyphicon glyphicon-envelope'
}

@b3.promptPassword = @b3.Alert::curry {
    dialog: true
    confirmation: true
    label: ''
    type: 'info'
    buttonText: ""
    region: 'middleCenter'
    block: 'alert-block'
    inputType: 'password'
    validation: "data-password=6"
    selectClass: 'password'
    header: 'Enter Password'
    icon: "glyphicon glyphicon-log-in"
}
@b3.confirmIdentity = @b3.Alert::curry {
    dialog: true
    confirmation: false
    buttonText: 'RESET'
    buttonClass: 'warning'
    showAltButton: false
    region: 'middleCenter'
    altButtonText: " change e-mail."
    altSelectClass: "changeUser"
    type: 'info'
    selectClass: 'identity'
    block: 'alert-block'
    inputType: 'text'
    header: 'New?'
    label: "Password Reset"
    icon: 'glyphicon glyphicon-envelope'
}

dyna.nextStep = (step)=>
    repeatStep = Session.equals('dynaStep', step)
    if not repeatStep then @b3.Alert::remove { dialog: true }
    Session.set('dynaStep', step)
    dyna.resetThrottle()
    switch step
        when 'init'
            if not Meteor.user()
                @b3.flashInfo ' please sign up or sign in.', { header: 'Welcome:' }
        when 'identify' #authorization begins;
            if not dyna.valid and repeatStep
                @b3.promptIdentity 'Invalid', {
                    single: 'identify'
                    value: dyna.identity
                    header: dyna.userEmail
                    type: 'warning'
                }
            else
                @b3.promptIdentity "", {
                    single: 'identify'
                }
            return
        when 'confirmation' #confirm identity then password.
            dyna.confirmation = true
            if not dyna.valid or repeatStep
                @b3.confirmIdentity 'Invalid input.', {
                    single: 'confirmation'
                    value: dyna.identity
                    type: 'warning'
                    label: dyna.emailMaybe
                }
            else
                @b3.confirmIdentity 'Please confirm:', {
                    single: 'confirmation'
                    placeholder: dyna.identity
                    label: dyna.emailMaybe
                }
            return
        when 'signUpNew', 'signBack' #enter password
            if (not dyna.valid) or (repeatStep)
                @b3.promptPassword 'Invalid', {
                    single: 'password'
                    type: 'warning'
                }
            else
                @b3.promptPassword "", {
                    single: 'password'
                }
            return

        when 'forgot' #forgot password
            if not dyna.valid and repeatStep
                @b3.confirmIdentity 'Reset Password', {
                    confirmation: true
                }

        else
            return

dyna.reset = =>
    dyna.userEmail = 'invalid e-mail'
    dyna.userExisting = false
    dyna.identity = ''
    dyna.emailMaybe = ''
    dyna.confirmation = false
    dyna.valid = true
    @b3.Alert::clearAll()
    return true

dyna.passwordReset = ->
    b3.confirmIdentity 'Confirm e-mail for password reset', {
        header: dyna.emailMaybe
        type: 'info'
        selectClass: 'forgotPassword'
    }

Template.dynaSignAlert.created = ->
    dyna.reset()
    if Meteor.user()
        dyna.identity = Meteor.user().emails[0].address
        dyna.emailMaybe = dyna.identity
        dyna.nextStep 'finished'
    else
        dyna.nextStep 'init'

Template.dynaSignAlert.button = ->
    step = Session.get 'dynaStep'
    switch step
        when 'init', 'identify'
            return {
                textL: 'Join!'
                styleL: 'btn-primary'
                iconL: ''
                textR: ''
                styleR: 'btn-success'
                iconR: 'glyphicon glyphicon-log-in'
                size: ''
                tooltipR: 'Log in.'
                tooltipL: 'Sign up!'
            }
        when 'confirmation'
            return {
                textL: dyna.emailMaybe
                styleL: 'btn-warning'
                iconL: 'glyphicon glyphicon-warning-sign'
                textR: ''
                styleR: 'btn-danger'
                iconR: 'glyphicon glyphicon-remove-sign'
                size: ''
                tooltipR: 'Change email.'
                tooltipL: 'Unconfirmed email.'
            }
        when 'signUpNew'
            return {
                textL: dyna.emailMaybe
                styleL: 'btn-info'
                iconL: 'glyphicon glyphicon-question-sign'
                textR: ''
                styleR: 'btn-danger'
                iconR: 'glyphicon glyphicon-remove-sign'
                size: ''
                tooltipR: 'Change email.'
                tooltipL: 'Is this your correct email?'
            }
        when 'signBack'
            return {
                textL: ""
                styleL: 'btn-success'
                iconL: 'glyphicon glyphicon-user'
                textR: 'Password'
                styleR: 'btn-inverse btn-default'
                iconR: 'glyphicon glyphicon-question-sign'
                size: ''
                tooltipR: 'Reset password'
                tooltipL: 'Change email?'
            }
        when 'finished' # logged in? or somethings wrong.
            return {
                textL: dyna.emailMaybe
                styleL: 'btn-inverse'
                iconL: 'glyphicon glyphicon-user'
                textR: ''
                styleR: 'btn-danger'
                iconR: 'glyphicon glyphicon-log-out'
                size: 'btn-xs'
                tooltipL: 'Go to dashboard.'
                tooltipR: 'Log out.'
            }
        when 'forgot'
            return {
                textL: 'Join!'
                styleL: 'btn-primary'
                iconL: ''
                textR: ''
                styleR: 'btn-success'
                iconR: 'glyphicon glyphicon-log-in'
                size: ''
                tooltipR: 'Log in.'
                tooltipL: 'Sign up!'
            }
Template.dynaSignAlert.events
    'click button#dynaButtonLeft': (e, t) ->
        console.log 'dynaSignClickLeft', e
        step = Session.get('dynaStep')
        switch step
            when 'init'
                b3.flashInfo ' please provide an email.', {
                    header: 'Hello!'
                }
                b3.flashInfo ' only important emails.', {
                    region: 'bottomLeft'
                    header: 'No spam:'
                }
                dyna.nextStep 'identify'
            when 'identify'
                dyna.reset()
                dyna.nextStep 'init'
            when 'finished'
                b3.flashInfo 'This is a dashboard flash.'
            when 'confirmation', 'signUpNew', 'signBack'
                b3.flashInfo 'Correct identification.'
                dyna.nextStep 'identify'
            when 'forgot'
                b3.flashInfo 'Request an email to reset your password.'
                dyna.nextStep 'forgot'
                #send reset password link
            else
                console.log 'error'

    'click button#dynaButtonRight': ( e, t ) ->
        console.log 'click'
        switch Session.get 'dynaStep'
            when 'init'
                b3.flashSuccess 'please authenticate.', { header: 'Welcome:' }
                dyna.nextStep 'identify'
            when 'identify', 'confirmation'
                console.log 'ic'
                b3.flashInfo ' RESET', { header: 'Identity:' }
                dyna.nextStep 'init'
            when 'signBack', 'forgot'
                b3.flashInfo 'Request an email to reset your password.'
                dyna.nextStep 'forgot'
                dyna.passwordReset()
            when 'signUpNew'
                b3.flashInfo 'a mix of letters and numbers known secretly by you.', { header: 'Password:' }
                dyna.nextStep 'signUpNew'
            when 'finished'
                console.log 'finished'
                return Meteor.logout(->
                    dyna.reset()
                    b3.flashInfo 'Logout complete.', { single: 'logout' }
                    dyna.nextStep 'init'
                )
            else
                throw new Meteor.error 415, 'dynaDign state invalid.'

    'mouseenter button': ( e, t ) ->
        $(e.target).tooltip('toggle')
