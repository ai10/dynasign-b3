
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
    'change, keyup input#emailInput': accountEvents.inputEmail
    'change, keyup input#emailReEnter': accountEvents.emailReEnter
    'change, keyup input#passwordInput': accountEvents.inputPassword
    'keydown input': (e, t) ->
        console.log 'keydown'
        if e.keyCode is 13
            e.preventDefault()
            return
    'click button#signUpNew': accountEvents.signUpNew
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

