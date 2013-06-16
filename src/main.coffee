
class State

    constructor: (@done = false) ->


class Point

    constructor: (@x = 0, @y = 0) ->


class Range

    constructor: (@top = 0, @bottom = 0, @left = 0, @right = 0) ->

    unitX: -> @left + @right + 1

    unitY: -> @top + @bottom + 1


class Color

    @list = [
        @RED    = new @ '#FF0000', 'red'
        @BLUE   = new @ '#0000FF', 'blue'
        @PURPLE = new @ '#800080', 'purple'
        @GREEN  = new @ '#008000', 'green'
    ]

    constructor: (@hex, @name) ->

    toString: ->
        @name


class CellModel

    constructor: ->
        @typeHash = {}
        @nameHash = {}

    add: (element) ->
        @typeHash[element.constructor] = element

    get: (type) ->
        @typeHash[type]

    gets: (types...) ->

        obj = {}

        for type in types when type of @typeHash

            unless type of @nameHash
                key = type.toString().match /^function (.)([^\(]+)/
                key = key[1].toLowerCase() + key[2]
                @nameHash[type] = key

            obj[@nameHash[type]] = @get type

        obj


class GridModel

    constructor: (width = 0, height = 0) ->

        @row = _.arrayInit height, ->
            _.arrayInit width, ->
                new CellModel

        @col = _.arrayInit width, (i) =>
            _.arrayInit height, (j) =>
                @row[j][i]

    height: -> @row.length
    width: -> @col.length

    getRow: (index) -> @row[index]
    getCol: (index) -> @col[index]

    getCell: (x, y) ->

        return null if x < 0 or x >= @width()
        return null if y < 0 or y >= @height()

        @getRow(y)[x]


class Calculate

    constructor: (@grid) ->

    getCellRange: (cell) ->

        point = cell.get Point
        range = cell.get Range

        list =
            top:    @grid.getCell point.x, point.y - range.top - 1
            bottom: @grid.getCell point.x, point.y + range.bottom + 1
            left:   @grid.getCell point.x - range.left - 1, point.y
            right:  @grid.getCell point.x + range.right + 1, point.y

        for key, value of list
            list[key] = value?.get Range

        list

    hasMatch: (foo, bar) ->

        return if foo is bar

        [foo, bar] = (item.gets Point, Range for item in [foo, bar])

        [top, bottom] = `foo.point.y < bar.point.y ? [foo, bar] : [bar, foo]`
        [left, right] = `foo.point.x < bar.point.x ? [foo, bar] : [bar, foo]`

        absX = right.point.x - left.point.x
        absY = bottom.point.y - top.point.y

        if foo.point.y is bar.point.y and absX is left.range.right + 1
            return true

        if foo.point.x is bar.point.x and absY is top.range.bottom + 1
            return true

        if top is left
            if top.range.bottom >= absY and bottom.range.left >= absX
                return true
            if bottom.range.top >= absY and top.range.right >= absX
                return true
        else
            if top.range.bottom >= absY and bottom.range.right >= absX
                return true
            if bottom.range.top >= absY and top.range.left >= absX
                return true

        false

    markMatch: (cell) ->

        state = cell.get State
        state.done = true

        range = cell.get Range

        cellRange = @getCellRange cell

        cellRange.bottom?.top = range.unitY()
        cellRange.top?.bottom = range.unitY()

        cellRange.right?.left = range.unitX()
        cellRange.left?.right = range.unitX()


angular.module('controller')

    .controller 'PanelCtrl', class

        constructor: ->

            @list = []

            grid = new GridModel 7, 7

            for y in _.range grid.height()
                @list[y] = []
                for x in _.range grid.width()

                    item = @list[y][x] =
                        state: new State
                        point: new Point x, y
                        range: new Range
                        color: _.shuffle(Color.list)[0]

                    cell = grid.getCell x, y
                    cell.add value for key, value of item

                    item.cell = cell

            @calulate = new Calculate grid

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

            return unless @calulate.hasMatch item.cell, prev.cell

            for i in [item, prev]
                @calulate.markMatch i.cell

            @prev.click = false
            @prev = null
