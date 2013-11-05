dyna = @dyna
dyna.signIn =  ( e, t, alert) ->
    email = e.target.value
    console.log 'signIn', email
    inputEmail e, t, (r, dum)=>
        console.log 'rdum', r, dum, alert
        if r is false then return
        console.log 'alert', alert
        b3.Alert::remove alert
        if r is 'invalid'
            console.log 'invalid'
            if dum?
                b3.promptEmail dum, {
                    value: dum
                    type: 'warning'
                    header: 'Did you mean?'
                }
            else
                b3.promptEmail email, {
                    value: email
                    type: 'warning'
                    header: 'enter valid e-mail'
                }
            return

        if r is 'new user'
            b3.alertConfirmEmail e.target.value, {
                placeholder: e.target.value
                header: "Please confirm:"
                label: "Re-enter #{e.target.value}"
            }
            return
        if r is 'existing user'
            b3.alertEnterPassword()
            return

