dyna = @dyna
Template.b3Alert.events
    'keyup input.identity': (e, t) ->
        dyna.identity = e.target.value

        initial_cb = (e, t) ->
            return dyna.identifyUnconfirmed e, t

        confirm_cb = ( e, t ) ->
            return dyna.confirmIdentity e, t

        forgot_cb = ( e, t ) ->
            if e.keyCode is 13
                return dyna.forgotPassword e, t, { firm: true }
            return dyna.forgotPassword e, t, { firm: false }


        switch Session.get('dynaStep')
            when 'confirmation' then cb = confirm_cb
            when 'forgot' then cb = forgot_cb
            else
                cb = initial_cb

        dyna.inputThrottle e, t, cb

    'keyup input.password': (e, t) ->
        dyna.password = e.target.value

        back_cb = ( e, t ) ->
            dyna.signBack e, t
            return

        upNew_cb = ( e, t ) ->
            dyna.signUpNew e, t
            return

        resetPass_cb = ( e, t ) ->
            dyna.resetPasword e, t
            return
        cb = back_cb
        if Session.equals('dynaStep', 'signUpNew')
            cb = upNew_cb
            dyna.keyCount = 1
            if e.keyCode isnt 13 then return

        if Session.equals('dynaStep', 'resetPassword')
            cb = resetPass_cb
            dyna.keyCount = 1
            if e.keyCode isnt 13 then return

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

        if step is 'resetPassword'
            return dyna.resetPassword e, t

        dyna.nextStep 'resetPassword'

    'click button.identity': ( e, t) ->
        i = t.find('input')
        dyna.identity = $(i).val()
        alert = @_id
        initial_cb = (e, t) =>
            return dyna.identifyUnconfirmed e, t, alert

        confirm_cb = ( e, t ) =>
            return dyna.confirmIdentity e, t, alert

        forgot_cb = ( e, t ) =>
            return dyna.forgotPassword e, t, { firm: true }

        cb = initial_cb

        if Session.equals('dynaStep', 'confirmation')
            cb = confirm_cb

        if Session.equals('dynaStep', 'forgot')
            cb = forgot_cb

        dyna.inputThrottle e, t, cb

    'click button.changeUser': ( e, t ) ->
        dyna.reset()
        dyna.nextStep 'identify'

