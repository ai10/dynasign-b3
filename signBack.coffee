dyna = @dyna
dyna.signBack = ( e , t )->
    e.preventDefault()
    f = t.firstNode?.form || e.target.form
    $f = $ f
    hasError=false
    dyna.valid = $(f).find('input.password').parsley('validate')
    dyna.valid or= $(f).find('input#password').parsley('validate')
    password = $f.find('input.password').val()
    if not (/\d/.test password)
        hasError = true
    if not (/\D/.test password)
        hasError = true
    if password.length < 6
        hasError = true
    if hasError
        b3.flashWarn 'requires a digit, non-digit letter, with minimum length of 6.', {
            header: 'Invalid Password'
            single: 'dynaPass'
        }
    if (not dyna.valid or hasError) then return
    if Session.equals('dynaStep', 'reset')
        token = Session.get('dynaToken')
        b3.flashInfo 'reseting password', { single: 'reset' }
        return Accounts.resetPassword token, password, (error)->
            if error?
                b3.flashError error.reason, { single: 'reset' }
            else
                b3.flashSuccess 'password is now reset.', { single: 'reset' }

    email = dyna.emailMaybe

    if dyna.userExisting isnt true
        b3.flashInfo 'Unknown user.'
        return dyna.nextStep 'identify'
    if Meteor.userId()
        b3.flashInfo 'Already logged in.'
        return dyna.nextStep 'finished'
    if Meteor.loggingIn()
        b3.flasInfo 'logging in to server ...'
        return dyna.nextStep 'init'

    Meteor.loginWithPassword email, password, (error)=>
        if error?
            Session.set 'dynaTooltipText', error.reason
            b3.flashError error.reason, {
                header: 'Login Error:'
                single: 'dynaPass'
            }
            dyna.nextStep 'signBack'
        else
            b3.flashSuccess email, {
                header: 'Authenticated:'
                single: 'dynaPass'
            }
            dyna.nextStep 'finished'
