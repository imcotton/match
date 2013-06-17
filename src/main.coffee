
class State

    constructor: (@done = false) ->


class Point

    constructor: (@x = 0, @y = 0) ->

    toString: ->
        "#{@x}-#{@y}"


class Range

    constructor: (@top = 0, @bottom = 0, @left = 0, @right = 0) ->

    unitX: -> @left + @right + 1

    unitY: -> @top + @bottom + 1

    markX: (point) -> ((1 << @unitX()) - 1) << point.x - @left

    markY: (point) -> ((1 << @unitY()) - 1) << point.y - @top


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

        [leftMarks, rightMarks] = (getMarkBits item for item in [left, right])

        if result = getBitAdd leftMarks.x, rightMarks.x
            for i in [0...result.length]
                list = @grid.getCol i + result.offset
                count = 0
                for j in [top.point.y..bottom.point.y]
                    count++ if list[j].get(State).done
                return true if count is absY + 1

        if result = getBitAdd leftMarks.y, rightMarks.y
            for i in [0...result.length]
                list = @grid.getRow i + result.offset
                count = 0
                for j in [left.point.x..right.point.x]
                    count++ if list[j].get(State).done
                return true if count is absX + 1

        false

    markMatch: (cell) ->

        state = cell.get State
        state.done = true

        range = cell.get Range

        cellRange = @_getCellRange cell

        cellRange.bottom?.top = range.unitY()
        cellRange.top?.bottom = range.unitY()

        cellRange.right?.left = range.unitX()
        cellRange.left?.right = range.unitX()

    _getCellRange: (cell) ->

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

    getMarkBits = (item) ->
        x: item.range.markX item.point
        y: item.range.markY item.point

    # TODO: cache
    getBitAdd = (a, b) ->

        result = a & b

        return false if result is 0

        result = result.toString(2).split('0').reverse()

        {
            offset: result.length - 1
            length: result[result.length - 1].length
        }


angular.module('controller')

    .controller 'PanelCtrl', class

        constructor: ->

            @list = []
            @hash = {}

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
