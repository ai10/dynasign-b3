dyna = @dyna

dyna.identifyUnconfirmed = ( e, t ) ->
    console.log 'identifyUnconfirmed', e.target.value
    e.preventDefault()
    f = t.firstNode || e.target.f
    dyna.valid = $(f).find('input.identity').parsley('validate')
    dyna.valid or= $(f).find('input#identity').parsley('validate')
    address = e.target.value
    keyCode = e.keyCode
    if not dyna.valid then return dyna.nextStep 'identify'
    console.log 'valid input', address, keyCode, dyna.valid
    if dyna.valid
        if not address then return dyna.nextStep()
        if address.length > 512
            throw new Meteor.Error 415, 'Stream exceeeds maximum length of 512.'
        return $.ajax
            type: "GET"
            url: 'https://api.mailgun.net/v2/address/validate?callback=?'
            data: { address: address, api_key: b3.validate_api_key }
            dataType: "jsonp"
            crossDomain: true
            success: (data, status) ->
                console.log 'mailgun result', data
                if not data.is_valid
                    dyna.confirmed = false
                    dyna.valid = false
                    if data.did_you_mean?
                        dyna.emailMaybe = data.did_you_mean
                    if not data.did_you_mean?
                        dyna.emailMaybe= ""
                        data.did_you_mean = 'something else..?'
                    Session.set 'dynaTooltipText', "#{address} invalid, did you mean #{data.did_you_mean}"
                    b3.flashWarn data.did_you_mean, {
                        header: "#{address} invalid, did you mean:"
                        single: 'dynaUser'
                    }
                    return dyna.nextStep('identify')
                if data.is_valid
                    dyna.valid = true
                    dyna.emailMaybe = address
                    Meteor.call 'checkIdentity', address, (error, result) ->
                        console.log 'checkidentity error, result', error, result
                        if error?
                            b3.flashError error.reason
                            return dyna.nextStep 'identify'
                        if result is false
                            dyna.confirmed = false
                            b3.flashInfo address, {
                                single: 'dynaUser'
                                header: 'New email, sign up!'
                            }
                            return dyna.nextStep 'confirmation'
                        else
                            if result?
                                dyna.confirmed = true
                                dyna.userExisting = true
                                b3.flashSuccess address, {
                                    header: 'Welcome back:'
                                    single: 'dynaUser'
                                }
                                b3.flashInfo 'Please enter  password.',{
                                    single: 'dynaPass'
                                }
                                return dyna.nextStep 'signBack'
                            else
                                return dyna.nextStep 'identify'
            error: (request, status, error) ->
                b3.flashError error.reason
                return dyna.nextStep 'identify'


