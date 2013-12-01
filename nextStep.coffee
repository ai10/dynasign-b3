dyna = @dyna
@b3.promptIdentity = @b3.Prompt::scurry {
    dialog: true
    confirmation: true
    buttonText: ""
    type: 'info'
    block: ''
    inputType: 'email'
    selectClass: 'identity'
    header: 'Authentication'
    label: 'Please enter your e-mail.'
    legend: 'Email.'
    placeholder: 'e-mail ...'
    icon: 'glyphicon glyphicon-envelope'
}

@b3.promptPassword = @b3.Prompt::scurry {
    dialog: true
    confirmation: true
    label: ''
    type: 'info'
    buttonText: ""
    block: ''
    inputType: 'password'
    validation: "data-password=6"
    selectClass: 'password'
    header: 'Authentication'
    legend: 'Password.'
    icon: "glyphicon glyphicon-log-in"
}
@b3.confirmIdentity = @b3.Prompt::scurry {
    dialog: true
    confirmation: false
    buttonText: ' RESET'
    buttonClass: 'warning'
    showAltButton: false
    altButtonText: " change e-mail."
    altSelectClass: "changeUser"
    type: 'info'
    selectClass: 'identity'
    block: 'alert-block'
    inputType: 'text'
    header: 'New?'
    label: ""
    legend: 'Confirm email.'
    icon: 'glyphicon glyphicon-envelope'
}
dyna.nextStep = (step)=>
    repeatStep = Session.equals('dynaStep', step)
    if not repeatStep then @b3.Prompt::remove { dialog: true }
    Session.set('dynaStep', step)
    dyna.resetThrottle()
    if Meteor.userId()
        dyna.emailMaybe = Meteor.user()?.emails[0]?.address
        switch step
            when 'resetPassword'
                @b3.promptPassword ' a new password', {
                    header:  'Enter:'
                    confirmation: true
                    single: 'resetPassword'
                }
                return
            else
                Session.set('dynaStep', 'finished')
                return

    switch step
        when 'init'
            @b3.flashInfo ' please sign up or sign in.', {
                header: 'Welcome:'
            }
        when 'identify' #authorization begins;
            if not dyna.valid and repeatStep
                @b3.promptIdentity 'Invalid email', {
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
                @b3.promptPassword 'Invalid password', {
                    single: 'password'
                    type: 'warning'
                }
            else
                @b3.promptPassword "", {
                    single: 'password'
                }
            return

        when 'forgot' #forgot password
            if (not dyna.valid) or (repeatStep)
                @b3.confirmIdentity dyna.emailMaybe, {
                    header: 'Confirm reset: '
                    confirmation: true
                    single: 'resetPassword'
                    value: dyna.identity
                    buttonClass: 'btn btn-danger'
                    buttonIcon: 'glyphicon glyphicon-refresh'
                    type: 'warning'
                    label: 'Re-enter email for password reset.'
                }
            else
                @b3.confirmIdentity dyna.emailMaybe, {
                    header: 'Confirm reset: '
                    confirmation: true
                    single: 'resetPassword'
                    buttonClass: 'btn btn-danger'
                    buttonIcon: 'glyphicon glyphicon-refresh'
                    type: 'warning'
                    label: 'Re-enter email for password reset.'
                }
        when 'resetPassword'
            if not dyna.valid or repeatStep
                @b3.promptPassword ' a new password', {
                    header: 'Enter:'
                    confirmation: true
                    single: 'resetPassword'
                }
            else
                @b3.promptPassword ' a new password', {
                    header:  'Enter:'
                    confirmation: true
                    single: 'resetPassword'
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
    @b3.Prompt::clearAll()
    return true


