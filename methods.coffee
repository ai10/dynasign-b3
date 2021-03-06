Meteor.methods
    checkIdentity: (email) ->
        check email, String
        if Meteor.isServer
            user = Meteor.users.findOne { 'emails.address': email }
            if user?
                return user
            else
                return false
        false

    completeVerify: (token) ->
        check token, String
        if Meteor.isServer
            u = Meteor.user()
            if not u?
                u = Meteor.users.findOne {
                    'services.email.verificationTokens.token': token
                }
            vTokens = u?.services?.email?.verificationTokens
            if vTokens?
                currentToken = _.findWhere vTokens, { token: token }
                if currentToken?
                    return currentToken.address
            false
