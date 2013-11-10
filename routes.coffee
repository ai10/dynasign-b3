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
                setTimeout(->
                    Router.go '/'
                ,
                2800
                )



    @route 'resetPassword',
        path: '/reset-password/:token'
        action: ->
            Session.set('dynaToken', @params.token)
            Session.set('dynaStep', 'reset')
            Session.set('dynaPasswordTooltip', 'Enter a new password.')
            b3.flashInfo 'Please enter a new password.'


