class Color

    @list = [
        new @ '#356B8A'
        new @ '#C84663'
        new @ '#62B422'
        new @ '#FF9666'
        new @ '#F0EDBB'
    ]

    constructor: (@hex, @name) ->

    toString: -> @name or @hex


angular.module('controller')

    .filter 'repeat', ->
        (amount, ingredient) ->
            new Array(amount + 1).join(ingredient)


    .controller 'MainCtrl', class

        constructor: (components, @$window, @$timeout) ->

            {
                State, Point, Range
                CellModel, GridModel, Calculate
            } = components

            @list = []
            @itemHash = {}
            @colorHash = {}
            @nextMatchs = []

            size = $window.location.search.match /^\?size=(\d+).(\d+)/
            size or= [0, 7, 7]

            grid = new GridModel size[1], size[2], CellModel

            for y in _.range grid.height()
                @list[y] = []
                for x in _.range grid.width()

                    item = @list[y][x] =
                        state: new State
                        point: new Point x, y
                        range: new Range

                    cell = grid.getCell x, y
                    cell.add value for key, value of item

                    item.color    = _.shuffle(Color.list)[0]
                    item.toString = -> @point.toString()

                    @itemHash[item] = cell

                    @colorHash[item.color] or= []
                    @colorHash[item.color].push item

            @calulate = new Calculate grid

            for key, value of @colorHash
                @colorHash[key] = _.shuffle value

            @checkPlayability()

        reload: ->
            @$window.location.reload()

        hasMatch: (foo, bar) ->
            @calulate.hasMatch (@getCell item for item in [foo, bar])...

        markMatch: (item) ->
            @calulate.markMatch @getCell item

        getCell: (item) ->
            @itemHash[item]

        getConnectable: ->

            unless @nextMatchs.length

                for color, list of @colorHash
                    @colorHash[color] = list =
                        _.filter list, (item) -> !item.state.done
                    delete @colorHash[color] if list.length < 2

                lists = _.values @colorHash

                return @nextMatchs unless lists[0]

                lists.push lists[_.random lists.length - 1]

                for list in lists by -1
                    for foo in [0...list.length - 1]
                        for bar in [foo + 1...list.length]
                            if @hasMatch list[foo], list[bar]
                                return @nextMatchs = [list[foo], list[bar]]

            @nextMatchs

        checkPlayability: ->
            unless @getConnectable().length
                @wellDone = true

        cellClick: (item) ->

            return if item.state.done

            unless @prev
                item.click = true
                @prev = item
                return

            return if item is @prev

            @prev.click = false
            item.click = true
            prev = @prev
            @prev = item

            return unless item.color is prev.color

            return unless @hasMatch item, prev

            @prev.click = false

            for i in [item, prev]
                @markMatch i
                if i in @nextMatchs
                    @nextMatchs.length = 0

            @prev = null

            @checkPlayability()

        hintOnce: ->
            @autoPlay true

        autoPlay: (once = false) ->

            @prev?.click = false
            @prev = null

            do run = =>
                matchs = @getConnectable()
                if matchs.length
                    @cellClick item for item in matchs
                    @$timeout run, 500 unless once
