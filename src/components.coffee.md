Literate CoffeeScript
=====================
_Code as documentation_

#### This file contains several classes provide for core logic of what so called _Match_ game

    ###
    Copyright (c) 2013 Cotton Hou

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    ###

State
-----

    class State

        constructor: (@done = false) ->

Point
-----

    class Point

        constructor: (@x = 0, @y = 0) ->

        toString: -> "#{@x}-#{@y}"

Range
-----

    class Range

        constructor: (@top = 0, @bottom = 0, @left = 0, @right = 0) ->

        unitX: -> @left + @right + 1

        unitY: -> @top + @bottom + 1

        markX: (offset) -> ((1 << @unitX()) - 1) << offset - @left

        markY: (offset) -> ((1 << @unitY()) - 1) << offset - @top

CellModel
---------
#### This is an _Entity_ like system, which uses composition rather than inheritance to organise related components

    class CellModel

        constructor: ->
            @typeHash = {}
            @nameHash = {}

        add: (instance) ->
            @typeHash[instance.constructor] = instance

        get: (clazz) ->
            @typeHash[clazz]

        gets: (types...) ->

            obj = {}

            for type in types when type of @typeHash

                unless type of @nameHash
                    key = type.toString().match(/^function (.)([^\(]+)/)
                    key = key[1].toLowerCase() + key[2]
                    @nameHash[type] = key

                obj[@nameHash[type]] = @get type

            obj

GridModel
---------
#### This creates _two_ 2-dimension Array internally in order to obtain lists of column data easily

    class GridModel

        constructor: (width = 0, height = 0, cellClass = Object) ->

            @row = []
            @col = []

            for i in [0...height]
                @row[i] = []
                for j in [0...width]
                    @row[i][j] = new cellClass

            for i in [0...width]
                @col[i] = []
                for j in [0...height]
                    @col[i][j] = @row[j][i]

        height: -> @row.length
        width: -> @col.length

        getRow: (index) -> @row[index]
        getCol: (index) -> @col[index]

        getCell: (x, y) ->

            return null if x < 0 or x >= @width()
            return null if y < 0 or y >= @height()

            @getRow(y)[x]

Calculate
---------
#### Major logic for calculation

    class Calculate

        constructor: (@grid) ->

        hasMatch: (foo, bar) ->

            return if foo is bar

            [foo, bar] = for item in [foo, bar]
                item.gets Point, Range

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

            [fooOuter, barOuter] = for item in [foo, bar]
                getOuterBits item, @grid.width(), @grid.height()

            return true if fooOuter & barOuter

            [fooMarks, barMarks] = (getMarkBits item for item in [foo, bar])

            if result = getBitAdd fooMarks.x, barMarks.x
                for i in [0...result.length]
                    list = @grid.getCol i + result.offset
                    for j in [top.point.y...bottom.point.y]
                        break unless list[j].get(State).done
                    return true if j is bottom.point.y

            if result = getBitAdd fooMarks.y, barMarks.y
                for i in [0...result.length]
                    list = @grid.getRow i + result.offset
                    for j in [left.point.x...right.point.x]
                        break unless list[j].get(State).done
                    return true if j is right.point.x

            false

        markMatch: (cell) ->

            state = cell.get State
            state.done = true

            range = cell.get Range

            cellRange = getCellRange @grid, cell

            cellRange.bottom?.top = range.unitY()
            cellRange.top?.bottom = range.unitY()

            cellRange.right?.left = range.unitX()
            cellRange.left?.right = range.unitX()

        getCellRange = (grid, cell) ->

            point = cell.get Point
            range = cell.get Range

            list =
                top:    grid.getCell point.x, point.y - range.top - 1
                bottom: grid.getCell point.x, point.y + range.bottom + 1
                left:   grid.getCell point.x - range.left - 1, point.y
                right:  grid.getCell point.x + range.right + 1, point.y

            for key, value of list
                list[key] = value?.get Range

            list

        getOuterBits = (item, width, height) ->
            result   = 0
            result  += item.point.y is item.range.top
            result <<= 1
            result  += item.point.y + item.range.bottom + 1 is height
            result <<= 1
            result  += item.point.x is item.range.left
            result <<= 1
            result  += item.point.x + item.range.right + 1 is width
            result

        getMarkBits = (item) ->
            x: item.range.markX item.point.x
            y: item.range.markY item.point.y

        getBitAdd = (a, b) ->

            result = a & b

            @hash or= 0: false

            return @hash[result] if result of @hash

            list = result.toString(2).split('0')

            @hash[result] =
                offset: list.length - 1
                length: list[0].length


exports
-------
#### Here is the place to export all classes in this file

    exports = {
        State, Point, Range, CellModel, GridModel, Calculate
    }

CommonJS Module if necessary

    unless module?.exports = exports

Otherwise bind to `this.components`, where in the browser `this` is `window` typically

        @components = exports
