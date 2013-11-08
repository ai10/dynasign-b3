dyna = @dyna
dyna.confirmed = false

throttlingTimeout = 0

dyna.resetThrottle = =>
    dyna.defaultLapse = 4321
    dyna.lastStamp = 0
    dyna.averageLapse = 0
    dyna.keyCount = 0
    dyna.difLapse = 0
    dyna.difTotal = 0
    dyna.calculatedLapse = dyna.defaultLapse

dyna.inputThrottle = (e, t, cb) ->
    unless throttlingTimeout is 0
        clearTimeout throttlingTimeout
    stamp = new Date().getTime()
    if dyna.keyCount++ is 0
        dyna.firstStamp = stamp
        return

    dyna.difLapse = stamp - dyna.lastStamp
    dyna.lastStamp = stamp
    dyna.difTotal = stamp - dyna.firstStamp
    dyna.averageLapse = dyna.difTotal/dyna.keyCount

    str = e.target.value

    if not str?
        click = true
        i = t.find('input')
        str = $(i).val()

    atat = str.indexOf("@")
    if atat < (dyna.keyCount - 1)
        if atat > -1
            dyna.calculatedLapse = 2*dyna.defaultLapse
        if atat = -1
            dyna.calculatedLapse = dyna.defaultLapse

    if atat is (dyna.keyCount - 1)
        dyna.calculatedLapse = 5*dyna.defaultLapse

    if (/\.com/.test(str) or /\.org/.test(str) or /\.net/.test(str) or /\.io/.test(str) or /\.me/.test(str) or /\.edu/.test(str))
        dyna.calculatedLapse = 100

    switch e.keyCode
        when 13 then lapse = 100
        when 8, 37, 39
            dyna.resetThrottle()
            dyna.keyCount = 1
            lapse = 4321
        else
            lapse = dyna.calculatedLapse
    if click then lapse = 100

    if dyna.keyCount > 5 then lapse = lapse/2

    throttlingTimeout = setTimeout(->
        cb(e, t)
    ,
        lapse
    )


