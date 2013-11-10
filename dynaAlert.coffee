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

        resetPass_cb = ( e, t ) =>
            dyna.resetPasword e, t
            return

        cb = back_cb
        if Session.equals('dynaStep', 'signUpNew')
            cb = upNew_cb
            unless e.keyCode is 13 then return

        if Session.equals('dynaStep', 'resetPassword')
            cb = resetPass_cb
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

