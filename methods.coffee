Meteor.methods
    checkIdentity: (email) ->
        if Meteor.isServer
            user = Meteor.users.findOne { 'emails.address': email }
            if user?
                return user
            else
                return false
        false

    completeVerify: (token) ->
        if Meteor.isServer
            u = Meteor.user()
            if u?.services?.email?.verficationTokens? is token then return true
            false

