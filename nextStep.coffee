dyna = @dyna
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


