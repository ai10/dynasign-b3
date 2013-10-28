Router.map ->
    @route 'verifyAccount',
        path: '/verify-email/:token'
        action: ->
            token = @params.token
            Accounts.verifyEmail token, (error)->
                if error?
                    b3.flashError error.reason
                else
                    b3.flashSuccess 'Account e-mail verification complete.'
            Router.go 'home'
    @route 'resetPassword',
        path: '/reset-password/:token'
        action: ->
            Session.set('dynaToken', @params.token)
            Session.set('dynaStep', 'reset')
            Session.set('dynaPasswordTooltip', 'Enter a new password.')
            b3.flashInfo 'Please enter a new password.'
            Router.go 'home'

Meteor.methods(
    checkIdentity: (email) ->
        if Meteor.isServer
            user = Meteor.users.findOne { 'emails.address': email }
            if user?
                return user
            else
                return false
        false
    sendVerification: (email) ->
        if Meteor.isServer
            if Meteor.userId()
                Accounts.sendVerificationEmail(Meteor.userId(), email)
                return true
            else
                if email?
                    user = Meteor.users.findOne { 'emails.address': email }
                    Accounts.sendVerificationEmail( user._id, email)
                    return true
                else
                    throw new Meteor.Error 415, 'cannot verify null user without email.'
)

b3.accountEvents = {}

b3.logInTimeout = 0

b3.accountEvents.logIn = (email, password) ->
    if Meteor.userId()
        return
    if Meteor.loggingIn()
        return
    b3.accountEvents.loginEmail = email
    b3.accountEvents.loginPassword = password
    unless b3.logInTimeout is 0
        clearTimeout b3.logInTimeout
    b3.logInTimeout = setTimeout(b3.accountEvents._logIn, 1000)

b3.accountEvents._logIn =  ->
    email = b3.accountEvents.loginEmail
    password = b3.accountEvents.loginPassword
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

b3.accountEvents.inputPassword = (e, t)->
    e.preventDefault()
    if (e.target.id isnt 'passwordInput') then return
    if e.keyCode is 13
        return b3.accountEvents.signPass(e, t)
    f = t.firstNode || e.target.f
    valid = $(f).find("input#passwordInput").parsley('validate')
    if valid
        Session.set('dynaPasswordTooltip', 'password valid')
        if Session.equals('dynaUserExisting', true)
            email = Session.get 'dynaEmailMaybe'
            return b3.accountEvents.logIn( email, e.target.value )
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

b3.accountEvents.inputEmail = ( e, t ) ->
    e.preventDefault()
    if (e.target.id isnt 'emailInput') then return
    address = e.target.value
    keyCode = e.keyCode
    f = t.firstNode || e.target.f
    valid = $(f).find('input#emailInput').parsley('validate')
    if valid
        if not address then return
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
                if data.is_valid
                    Session.set('dynaEmailValid', true)
                    if Session.equals('dynaStep', 1)
                        Session.set 'dynaEmailMaybe', address
                        Meteor.call 'checkIdentity', address, (err, result)->
                            if result is false
                                Session.set 'dynaUserExisting', false
                                if keyCode is 13
                                    return b3.accountEvents.signUpNew( e, t )
                                b3.flashInfo address, {
                                    single: 'dynaUser'
                                    header: 'New email, sign up!'
                                }
                                return false
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
                                    return true
                                else
                                    return false
            error: (request, status, error) ->

b3.accountEvents.emailReEnter = ( e, t ) ->
    if (e.target.id isnt 'emailReEnter') then return
    f = t.firstNode || e.target.form
    valid = $(f).find('input#emailReEnter').parsley('validate')
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
    false

b3.accountEvents.signPass = ( e , t )->
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
        return b3.accountEvents.logIn(email, password)

    profile = b3.accounts?.defaultProfile? || {}
    Accounts.createUser({
        email: email,
        password: password,
        profile: profile
    }, (error)->
        if error?
            b3.flashError error.reason, { single: 'dynaPass' }
        else
            b3.flashSuccess 'Welcome! Thanks for signing up.'
            Meteor.call 'sendVerification', email,(error, result) ->
                if error?
                    b3.flashError error.reason
                    return false
                if result?
                    b3.flashInfo "A verification e-mail should be delivered to #{email} shortly"
            Session.set('dynaStep', 0)
    )
    false

b3.accountEvents.signUpNew = ( e, t ) ->
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


b3.accountEvents.signOut = ->

Meteor.startup( ->
    Session.set 'dynaStep', 1
    Session.set 'dynaUserExisting', false
    Session.set 'dynaUserAuthenticated', false
    Session.set 'dynaEmailMaybe', ""
    Session.set 'dynaEmailValid', false
    Session.set 'dynaEmailTooltip', 'e-mail sign in.'
    Session.set 'dynaPasswordTooltip', 'password'
    )

Template.dynaSign.created = ()->

Template.dynaSign.destroyed = ->
    'dynaSign destroyed'

Template.dynaSign.rendered = ->
    if Meteor.user()
        Session.set('dynaStep', 0)
        Session.set('dynaUserExisting', true)
        Session.set('dynaEmailValid', true)
        Session.set('dynaEmailMaybe', Meteor.user().emails[0].address)

    f = @firstNode
    $(f)?.parsley('destroy')?.parsley b3.parsley

Template.dynaSign.helpers
    dynaEmailMaybe: ->
        if Session.equals('dynaEmailValid', true)
            return Session.get('dynaEmailMaybe')
        else
            return ""
    emailTooltip: ->
        Session.get('dynaEmailTooltip')
    passwordTooltip: ->
        Session.get('dynaPasswordTooltip')

    signedInAs: ->
        Meteor.user().username ?
        (Meteor.user().profile?.name ?
        (Meteor.user().emails[0]?.address ? "Logged In"))
    showStep3: ->
        if Session.equals('dynaStep', 3) then return ""
        if Session.equals('dynaStep', 'reset') then return ""
        "hidden"
    showStep2: ->
        if Session.equals('dynaStep', 2) then return ""
        "hidden"
    showStep1: ->
        if Session.equals('dynaStep', 1) then return ""
        "hidden"
    showChangeUser: ->
        if Session.equals('dynaStep', 1) then return "hidden"
        ""
    showComplete: ->
        if Session.equals('dynaStep', 3)
            if Session.equals('dynaUserExisting', false) then return ""
        if Session.equals('dynaStep', 'reset') then return ""
        "hidden"
    showNew: ->
        if Session.equals('dynaStep', 1)
            if Session.equals('dynaEmailValid', true)
                if Session.equals('dynaUserExisting', false) then return ""
        "hidden"
    showSignIn: ->
        if Session.equals('dynaStep', 3)
            if Session.equals('dynaUserExisting', true) then return ""
        "hidden"

Template.dynaSign.events
    'change, keyup input#emailInput': b3.accountEvents.inputEmail
    'change, keyup input#emailReEnter': b3.accountEvents.emailReEnter
    'change, keyup input#passwordInput': b3.accountEvents.inputPassword
    'keydown input': (e, t) ->
        if e.keyCode is 13
            e.preventDefault()
            return
    'click button#signUpNew': b3.accountEvents.signUpNew
    'click button#signUpComplete': b3.accountEvents.signPass
    'click button#signIn': b3.accountEvents.signPass
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

