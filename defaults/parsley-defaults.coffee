@b3.parsley = {
        inputs: 'input'
        excluded: 'input[type=hidden]'
        trigger: 'input change focusin'
        focus: 'first'
        validationMinLength: 3
        errorClass: 'has-error'
        successClass: 'has-success'
        validators:
            hasnumber: (val) ->
                if not /[0-9]/.test(val)
                    return false
                true
            hasletter: (val) ->
                if not /[a-z]/i.test(val)
                    return false
                true
        showErrors: true
        messages:
            hasnumber: ""
            hasletter: ""

        validateIfUnchanged: true
        errors:
            classHandler: (e, r) ->
                p = e.parent()

            container: (e, r) ->
                p = e.parent()
                s = "div##{e.context.id}.tooltip"
                pop = $(s)
                $c= pop.find('.tooltip-title')
                if $c.length is 0
                    $('form-group').tooltip 'hide'
                    $(p).tooltip 'show'
                    $n = pop.find('.tooltip-title')
                    return $n
                return $c
            errorsWrapper: '<ul></ul>'
            errorElem: '<li></li>'
        listeners:
            onFieldValidate: ->
            onFormSubmut: ->
            onFieldError: ->
            onFieldSuccess: (elem) ->

}
