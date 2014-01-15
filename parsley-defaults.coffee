@b3.parsley = {
        inputs: 'input'
        excluded: 'input[type=hidden]'
        trigger: 'input change focusin'
        focus: 'first'
        validationMinLength: 3
        errorClass: 'has-error'
        successClass: 'has-success'
        showErrors: true
        useHtml5Constraints: true
        messages:
            password: "Insufficiently complex."
            email: "e.g. example@host.net"

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
