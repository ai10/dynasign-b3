Router.map ->
    @route 'verifyEmail',
        path: '/verify-email/:token'
        action: ->
            token = @params.token
            Meteor.call 'completeVerify', token, (error, result)->
                if error?
                    b3.flashError error.reason
                if result?
                    if result is false
                        b3.flashError "token does not match."
                    else
                        dyna.emailMaybe = result
                        b3.flashSuccess "#{result} verified."
                        Session.set 'dynaStep', 'finished'
                setTimeout(->
                    Router.go '/'
                ,
                2800
                )
            @render()



    @route 'resetPassword',
        path: '/reset-password/:token'
        action: ->
            token = @params.token
            Session.set('dynaToken', token)
            dyna.nextStep 'resetPassword'
            @render()
