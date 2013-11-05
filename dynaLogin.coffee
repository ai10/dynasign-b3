logInTimeout = 0

@dynaLogin = dynaLogin = (email, password) ->
    if Meteor.userId()
        return
    if Meteor.loggingIn()
        return
    @email = email
    @password = password
    unless logInTimeout is 0
        clearTimeout logInTimeout
    logInTimeout = setTimeout(_dynaLogin, 1000)

_dynaLogin =  ->
    email = dynaLogin.email
    password = dynaLogin.password
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


