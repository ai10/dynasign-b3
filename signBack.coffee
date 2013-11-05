dyna = @dyna
dyna.signBack = ( e , t )->
    e.preventDefault()
    f = t.firstNode?.form || e.target.form
    $f = $ f
    hasError=false
    password = $f.find('input.enterPassword').val()
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

    email = dyna.emailMaybe

    if dyna.userExisting isnt true
        Session.set 'dynaStep', 1
        return dyna.nextStep()
    if Meteor.userId()
        Session.set 'dynaStep', 5
        return dyna.nextStep()
    if Meteor.loggingIn()
        Session.set 'dynaStep', 4
        return dyna.nextStep()

    Meteor.loginWithPassword email, password, (error)=>
        if error?
            Session.set 'dynaTooltipText', error.reason
            b3.flashError error.reason, {
                header: 'Login Error:'
                single: 'dynaPass'
            }
            Session.set('dynaStep', 4)
        else
            b3.flashSuccess email, {
                header: 'Authenticated:'
                single: 'dynaPass'
            }
            Session.set('dynaStep', 5)
        dyna.nextStep()
