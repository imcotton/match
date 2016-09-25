
import { State, Point, Range, CellModel, GridModel } from './engine'





export class Calculator

    constructor: (@grid) ->

    hasMatch: (foo, bar) ->

        return false if foo is bar

        [foo, bar] = [foo, bar].map (cell) ->
            [point, range] = [Point, Range].map cell.get
            {point, range}

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
            getOuterBits item, @grid.width, @grid.height

        return true if fooOuter & barOuter

        [fooMarks, barMarks] = [foo, bar].map getMarkBits

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

    markMatch: (cell) =>

        state = cell.get State
        state.done = true

        range = cell.get Range

        cellRange = getCellRange @grid, cell

        cellRange.bottom?.top = range.unitY
        cellRange.top?.bottom = range.unitY

        cellRange.right?.left = range.unitX
        cellRange.left?.right = range.unitX

        return @

    getCellRange = (grid, cell) ->

        [point, range] = [Point, Range].map cell.get

        list =
            top:    grid.getCell point.x, point.y - range.top - 1
            bottom: grid.getCell point.x, point.y + range.bottom + 1
            left:   grid.getCell point.x - range.left - 1, point.y
            right:  grid.getCell point.x + range.right + 1, point.y

        for key, value of list
            list[key] = value?.get Range

        return list

    getOuterBits = (item, width, height) ->
        result   = 0
        result  += item.point.y is item.range.top
        result <<= 1
        result  += item.point.y + item.range.bottom + 1 is height
        result <<= 1
        result  += item.point.x is item.range.left
        result <<= 1
        result  += item.point.x + item.range.right + 1 is width

        return result

    getMarkBits = (item) -> {
        x: item.range.markX item.point.x
        y: item.range.markY item.point.y
    }

    hash = 0: false

    getBitAdd = (a, b) ->

        result = a & b

        return hash[result] if result of hash

        list = result.toString(2).split('0')

        hash[result] =
            offset: list.length - 1
            length: list[0].length

