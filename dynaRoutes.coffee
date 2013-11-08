Router.map ->
    @route 'verifyAccount',
        path: '/verify-email/:token'
        action: ->
            token = @params.token
            console.log 'verify-email token', token
            Accounts.verifyEmail token, (error)->
                if error?
                    console.log 'error', error, token
                    b3.flashError error.reason
                else
                    console.log 'success'
                    b3.flashSuccess 'Account e-mail verification complete.'

    @route 'resetPassword',
        path: '/reset-password/:token'
        action: ->
            Session.set('dynaToken', @params.token)
            Session.set('dynaStep', 'reset')
            Session.set('dynaPasswordTooltip', 'Enter a new password.')
            b3.flashInfo 'Please enter a new password.'


