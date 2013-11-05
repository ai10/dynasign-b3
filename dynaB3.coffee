console.log 'dynaSign'
dyna = @dyna = {}
dyna.confirmed = false
throttlingTimeout = 0
dyna.inputThrottle = (e, t, cb) ->
    console.log 'throttle', e.target.value
    unless throttlingTimeout is 0
        clearTimeout throttlingTimeout
    lapse = 1234
    if e.keyCode is 13 then lapse = 100
    throttlingTimeout = setTimeout(->
        cb(e, t)
    ,
        lapse
    )


