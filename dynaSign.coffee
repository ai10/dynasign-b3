console.log 'dynaSign'
Router.map ->
    @route 'verifyAccount',
        path: '/verify-email/:token'
        action: ->
            token = @params.token
            console.log 'verify-email token', token
            Accounts.verifyEmail token, (error)->
                if error?
                    console.log 'error', error, token
                    b3.flashError error.reason
                else
                    b3.flashSuccess 'Account e-mail verification complete.'
                Router.go '/'

    @route 'resetPassword',
        path: '/reset-password/:token'
        action: ->
            Session.set('dynaToken', @params.token)
            Session.set('dynaStep', 'reset')
            Session.set('dynaPasswordTooltip', 'Enter a new password.')
            b3.flashInfo 'Please enter a new password.'

accountEvents = @accountEvents = {}

logInTimeout = 0

accountEvents.logIn = (email, password) ->
    if Meteor.userId()
        return
    if Meteor.loggingIn()
        return
    accountEvents.loginEmail = email
    accountEvents.loginPassword = password
    unless logInTimeout is 0
        clearTimeout logInTimeout
    logInTimeout = setTimeout(accountEvents._logIn, 1000)

accountEvents._logIn =  ->
    email = accountEvents.loginEmail
    password = accountEvents.loginPassword
    Meteor.loginWithPassword email, password, (error)=>
        if error?
            Session.set 'dynaTooltipText', error.reason
            b3.flashError error.reason, {
                header: 'Login Error:'
                single: 'dynaPass'
            }
            Session.set('dynaUserAuthenticated', false)
        else
            b3.flashSuccess email, {
                header: 'Authenticated:'
                single: 'dynaPass'
            }
            Session.set('dynaStep', 0)

accountEvents.inputPassword = (e, t)->
    e.preventDefault()
    if (e.target.id isnt 'passwordInput') then return
    if e.keyCode is 13
        return accountEvents.signPass(e, t)
    f = t.firstNode || e.target.f
    valid = $(f).find("input#passwordInput").parsley('validate')
    if valid
        Session.set('dynaPasswordTooltip', 'password valid')
        if Session.equals('dynaUserExisting', true)
            email = Session.get 'dynaEmailMaybe'
            return accountEvents.logIn( email, e.target.value )
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
accountEvents.inputEmail = ( e, t, cb ) ->
    e.preventDefault()
    f = t.firstNode || e.target.f
    valid = $(f).find('input.signIn').parsley('validate')
    valid or= $(f).find('input#emailInput').parsley('validate')
    address = e.target.value
    keyCode = e.keyCode
    if not valid then return false
    console.log 'akv', address, keyCode, valid
    if valid
        if not address then return false
        if address.length > 512
            throw new Meteor.Error 415, 'Stream exceeeds maximum length of 512.'
        return $.ajax
            type: "GET"
            url: 'https://api.mailgun.net/v2/address/validate?callback=?'
            data: { address: address, api_key: b3.validate_api_key }
            dataType: "jsonp"
            crossDomain: true
            success: (data, status) ->
                if not data.is_valid
                    Session.set('dynaEmailValid', false)
                    if data.did_you_mean?
                        Session.set('dynaEmailMaybe', data.did_you_mean)
                    if not data.did_you_mean?
                        Session.set('dynaEmailMaybe', "")
                        data.did_you_mean = 'something else..?'
                    Session.set 'dynaTooltipText', "#{address} invalid, did you mean #{data.did_you_mean}"
                    b3.flashWarn data.did_you_mean, {
                        header: "#{address} invalid, did you mean:"
                        single: 'dynaUser'
                    }
                    Session.set('dynaStep', 1)
                    return cb? 'invalid', data.did_you_mean
                if data.is_valid
                    Session.set('dynaEmailValid', true)
                    if Session.equals('dynaStep', 1)
                        Session.set 'dynaEmailMaybe', address
                        Meteor.call 'checkIdentity', address, (error, result) ->
                            if error?
                                b3.flashError error.reason
                                return false
                            if result is false
                                Session.set 'dynaUserExisting', false
                                if keyCode is 13
                                    return accountEvents.signUpNew( e, t )
                                b3.flashInfo address, {
                                    single: 'dynaUser'
                                    header: 'New email, sign up!'
                                }
                                return cb? 'new user'
                            else
                                if result?
                                    Session.set 'dynaUserExisting', true
                                    b3.flashSuccess address, {
                                        header: 'Welcome back:'
                                        single: 'dynaUser'
                                    }
                                    b3.flashInfo 'Please enter a password.',{
                                        single: 'dynaPass'
                                    }
                                    Session.set 'dynaStep', 3
                                    return cb? 'existing user'
                                else
                                    return false
            error: (request, status, error) ->
                b3.flashError error.reason
        return false

accountEvents.emailReEnter = ( e, t, cb ) ->
    f = t.firstNode || e.target.form
    valid = $(f).find('input#emailReEnter').parsley('validate')
    valid = valid || $(f).find('input.emailReEnter').parsley('validate')
    if not valid then return false
    if valid
        if Session.equals('dynaEmailMaybe', e.target.value)
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
        else
            target = Session.get('dynaEmailMaybe')
            b3.flashWarn target, {
                header: e.target.value+'- should match -'
                single: 'dynaUser'
            }
        cb?()
    false

accountEvents.signPass = ( e , t )->
    e.preventDefault()
    f = t.firstNode?.form || e.target.form
    $f = $ f
    hasError=false
    password = $f.find('input#passwordInput').val()
    if not (/\d/.test password)
        hasError = true
    if not (/\D/.test password)
        hasError = true
    if password.length < 6
        hasError = true
    if hasError
        b3.flashWarn 'requires a digit, non-digit letter, with minimum length of 6.', {header: 'Invalid Password', single: 'dynaPass' }
        return
    if Session.equals('dynaStep', 'reset')
        token = Session.get('dynaToken')
        return Accounts.resetPassword token, password, (error)->
            if error?
                b3.flashError error.reason
            else
                b3.flashSuccess 'password is now reset.'

    email = Session.get('dynaEmailMaybe')
    if Session.equals('dynaUserExisting', true)
        return accountEvents.logIn(email, password)

    profile = accounts?.defaultProfile? || {}
    console.log 'creating user', email, password, profile
    Accounts.createUser({
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, { single: 'dynaPass' }
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            b3.flashInfo "A verification e-mail should be delivered to #{email} shortly."
            Meteor.call 'sendVerificationEmail', email
            Session.set('dynaStep', 0)
    )
    false

accountEvents.signUpNew = ( e, t ) ->
    hasError = false
    e.preventDefault()
    f = t.firstNode?.form || e.target?.form
    $f= $ f
    if Session.equals('dynaStep', 1)
        emailMaybe = $f.find('input#emailInput').val()
        b3.flashInfo emailMaybe, {
            header: 'Please confirm e-mail:'
            single: 'dynaUser'
        }
        Session.set('dynaEmailMaybe', emailMaybe)
        Session.set('dynaStep', 2)
    return false


accountEvents.signOut = ->
alertEvents = {}

throttlingTimeout = 0
inputThrottle = (e, t, cb) ->
    console.log 'throttle', e.target.value
    unless throttlingTimeout is 0
        clearTimeout throttlingTimeout

    throttlingTimeout = setTimeout(->
        cb(e, t)
    ,
        2000
    )

alertEvents.signIn =  (e, t, alert) ->
    email = e.target.value
    console.log 'signIn', email
    accountEvents.inputEmail e, t, (r, dum)=>
        console.log 'rdum', r, dum, alert
        if r is false then return
        console.log 'alert', alert
        b3.Alert::remove alert
        if r is 'invalid'
            console.log 'invalid'
            if dum?
                b3.promptEmail dum, {
                    value: dum
                    type: 'warning'
                    header: 'Did you mean?'
                }
            else
                b3.promptEmail email, {
                    value: email
                    type: 'warning'
                    header: 'enter valid e-mail'
                }
            return

        if r is 'new user'
            b3.alertConfirmEmail e.target.value, {
                placeholder: e.target.value
                header: "Please confirm:"
                label: "Re-enter #{e.target.value}"
            }
            return
        if r is 'existing user'
            b3.alertEnterPassword()
            return

Template.b3Alert.events
    'keyup input.signIn': (e, t) ->
        alert = @_id
        cb = (e, t) =>
            console.log 'cb fired', alert
            return alertEvents.signIn e, t, alert

        inputThrottle e, t, cb

    'keyup input.emailReEnter': (e, t) ->
        alert = @_id
        cb = (e,t) =>
            return accountEvents.emailReEnter e, t, alert


            b3.Alert::remove @_id
            b3.alertConfirmPassword 'password', {
                placeholder: 'password'
                header: 'Please enter a password.'
            }
            return

        inputThrottle e, t, cb

    'change, keyup input.passwordInput': (e, t) ->
        cb = accountEvents.inputPassword e, t, =>
            b3.Alert::remove @_id
            return

        inputThrottle e, t, cb

    'keydown input': (e, t) ->
        if e.keyCode is 13
            e.preventDefault()
            return
    'click button.signIn': (e, t) ->
        cb = accountEvents.signUpNew e,t, =>
            b3.Alert::remove(@_id)
            b3.alertConfirmEmail '...', { placeholder: e.target.value }
        inputThrottle e, t, cb

    'click button#signUpNew': (e,t)->
    'click button#signUpComplete': accountEvents.signPass
    'click button#signIn': accountEvents.signPass
    'click button#changeUser': ( e, t)->
        e.preventDefault()
        Session.set 'dynaEmailMaybe', ""
        Session.set 'dynaEmailValid', false
        Session.set 'dynaUserExisting', false
        Session.set 'dynaStep', 1
        if Meteor.userId()
            Meteor.logout(->
                Session.set 'dynaEmailMaybe', ""
                Session.set 'dynaEmailValid', false
                Session.set 'dynaUserExisting', false
                Session.set 'dynaStep', 1
            )
        false
    'click button#forgotPass': ->
        if Session.equals('dynaUserExisting', true)
            email = Session.get 'dynaEmailMaybe'
            Accounts.forgotPassword { email: email }, (error)->
                if error?
                    b3.flashError 'Error:', error
                else
                    b3.flashSuccess "reset password link sent to #{email}"


@b3.promptEmail = @b3.Alert::curry {
    dialog: true
    type: 'info'
    block: 'alert-block'
    inputType: 'email'
    selectClass: 'signIn'
    header: 'Authentication.'
    label: 'e-mail'
    placeholder: 'e-mail ...'
    icon: 'glyphicon glyphicon-envelope'
}

@b3.alertConfirmPassword = @b3.Alert::curry {
    dialog: true
    type: 'info'
    block: 'alert-block'
    inputType: 'password'
    selectClass: 'enterPassword'
    header: 'Enter Password'
    icon: "glyphicon glyphicon-log-in"
}

@b3.alertEnterPassword = @b3.Alert::curry {
    dialog: true
    type: 'info'
    block: 'alert-block'
    inputType: 'password'
    selectClass: 'signIn'
    header: 'Enter Password'
    icon: "glyphicon glyphicon-log-in"
}

@b3.alertConfirmEmail = @b3.Alert::curry {
    dialog: true
    showAltButton: true
    altButtonText: " change e-mail."
    altSelectClass: "changeUser"
    type: 'info'
    selectClass: 'signUpNew'
    block: 'alert-block'
    inputType: 'text'
    header: 'New? Please confirm e-mail.'
    icon: 'glyphicon glyphicon-envelope'
}

