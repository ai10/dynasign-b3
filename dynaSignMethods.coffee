Meteor.methods(
    checkIdentity: (email) ->
        console.log 'checkidentity', email
        if Meteor.isServer
            user = Meteor.users.findOne { 'emails.address': email }
            if user?
                return user
            else
                return false
        false
    sendVerificationEmail: (email) ->
        if Meteor.isServer
            if Meteor.userId()
                id = Meteor.userId()
            #else
            #    u = Meteor.users.findOne { 'emails.address': email }
            #    if not u?
            #        throw new Meteor.E
            #    id = u._id
            console.log 'sending verification email', email
            vID = RandomGenerator.id()
            console.log vID

)
