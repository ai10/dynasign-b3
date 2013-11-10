dyna = @dyna
Template.dynaButton.created = ->
    dyna.reset()
    if Meteor.user()
        dyna.identity = Meteor.user().emails[0].address
        dyna.emailMaybe = dyna.identity
        dyna.nextStep 'finished'
    if Session.equals 'dynaStep', 'resetPassword'
        dyna.nextStep 'resetPassword'
    else
        dyna.nextStep 'init'

Template.dynaButton.button = ->
    step = Session.get 'dynaStep'
    switch step
        when 'init', 'identify', 'resetPassword'
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

Template.dynaButton.events
    'click button#dynaButtonLeft': (e, t) ->
        step = Session.get('dynaStep')
        switch step
            when 'init', 'resetPassword'
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

    'click button#dynaButtonRight': ( e, t ) ->
        switch Session.get 'dynaStep'
            when 'init'
                b3.flashSuccess 'please authenticate.', { header: 'Welcome:' }
                dyna.nextStep 'identify'
            when 'identify', 'confirmation'
                b3.flashInfo ' RESET', { header: 'Identity:' }
                dyna.nextStep 'init'
            when 'signBack', 'forgot'
                b3.flashInfo 'Request an email to reset your password.'
                dyna.nextStep 'forgot'
            when 'signUpNew'
                b3.flashInfo 'a mix of letters and numbers known secretly by you.', { header: 'Password:' }
                dyna.nextStep 'signUpNew'
            when 'finished'
                return Meteor.logout(->
                    dyna.reset()
                    b3.flashInfo 'Logout complete.', { single: 'logout' }
                    dyna.nextStep 'init'
                )
            else
                throw new Meteor.error 415, 'dynaDign state invalid.'

    'mouseenter button': ( e, t ) ->
        $(e.target).tooltip('toggle')
