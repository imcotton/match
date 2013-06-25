_.mixin

    rangeChain: (param...) ->
        _.chain _.range param...

    arrayInit: (num, fn) ->
        _.rangeChain(num)
            .map (n) ->
                if _.isFunction fn then fn n else fn
            .value()
