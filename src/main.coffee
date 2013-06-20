class Color

    @list = [
        @MAROON = new @ '#800000', 'maroon'
        @NAVY   = new @ '#000080', 'navy'
        @PURPLE = new @ '#800080', 'purple'
        @GREEN  = new @ '#008000', 'green'
        @TEAL   = new @ '#008080', 'teal'
        @OLIVE  = new @ '#808000', 'olive'
    ]

    constructor: (@hex, @name) ->

    toString: -> @name


angular.module('controller')

    .controller 'PanelCtrl', class

        constructor: (components) ->

            {
                State, Point, Range
                CellModel, GridModel, Calculate
            } = components

            @list = []
            @hash = {}

            grid = new GridModel CellModel, 7, 7

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

                    @hash[item] = cell

            @calulate = new Calculate grid

        getCell: (item) ->
            @hash[item]

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

            return unless @calulate.hasMatch @getCell(item), @getCell(prev)

            for i in [item, prev]
                @calulate.markMatch @getCell i

            @prev.click = false
            @prev = null
