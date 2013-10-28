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
    sendValidationEmail: (email) ->
        if Meteor.isServer
            if Meteor.userId()
                id = Meteor.userId()
            else
                u = Meteor.users.findOne { 'emails.address': email }
                id = u._id
            Accounts.sendVerificationEmail(id, email)

)
