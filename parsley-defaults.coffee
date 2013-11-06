@b3.parsley = {
        inputs: 'input'
        excluded: 'input[type=hidden]'
        trigger: 'input change focusin'
        focus: 'first'
        validationMinLength: 3
        errorClass: 'has-error'
        successClass: 'has-success'
        validators:
            password: (val, p) ->
                i = parseInt(p)
                console.log 'val, p, i', val, p, i
                if not /[0-9]/.test(val)
                    return false
                if not /[a-z]/i.test(val)
                    return false
                if val.lenth < i
                    return false
                true
        showErrors: true
        messages:
            password: "Requires %s character with letters and digits."

        validateIfUnchanged: true
        errors:
            classHandler: (e, r) ->
                p = e.parent()

            container: (e, r) ->
                p = e.parent()
                console.log 'e,r', e, r
                return e.context
            ### for putting comment into tooltip
                s = "div##{e.context.id}.tooltip"
                pop = $(s)
                $c= pop.find('.tooltip-title')
                if $c.length is 0
                    $('form-group').tooltip 'hide'
                    $(p).tooltip 'show'
                    $n = pop.find('.tooltip-title')
                    return $n
                return $c
            ###
            errorsWrapper: '<ul></ul>'
            errorElem: '<li></li>'
        listeners:
            onFieldValidate: ->
            onFormSubmut: ->
            onFieldError: ->
            onFieldSuccess: (elem) ->

}
