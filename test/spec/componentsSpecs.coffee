{State, Point, Range, CellModel, GridModel, Calculate} = components


describe 'loading modules', ->

    list = {State, Point, Range, CellModel, GridModel, Calculate}

    for key, value of list
        do (key, value) ->
            it "has component: #{key}", ->
                expect(value).toBeDefined()


describe 'components init check', ->

    it 'State', ->
        expect(new State().done).toBeFalsy()

    it 'Point', ->
        expect(new Point(3, 5).toString()).toEqual('3-5')

    it 'Range', ->
        range = new Range 2, 3, 4, 5
        expect(range.unitX()).toBe(10)
        expect(range.unitY()).toBe(6)
        expect(range.markX(4).toString(2)).toBe('1111111111')
        expect(range.markX(5).toString(2)).toBe('11111111110')
        expect(range.markX(6).toString(2)).toBe('111111111100')
        expect(range.markY(2).toString(2)).toBe('111111')
        expect(range.markY(6).toString(2)).toBe('1111110000')

    it 'CellModel', ->
        list =
            clazz:    [    State,           Point,           Range            ]
            instance: [new State(true), new Point(1, 2), new Range(3, 4, 5, 6)]

        cellModel = new CellModel()
        cellModel.add i for i in list.instance

        item = cellModel.gets State, Point, Range

        for i in [0...list.clazz.length]
            expect(cellModel.get(list.clazz[i])).toBe(list.instance[i])

        for k, v in item
            expect(v in list.instance).toBeTruthy()

    it 'GridModel', ->
        grid = new GridModel 3, 5, Array
        expect(grid.getCell(0, 0)).toEqual(jasmine.any(Array))
        expect(grid.width()).toBe(3)
        expect(grid.height()).toBe(5)
        expect(grid.getRow(1)[2]).toBe(grid.getCol(2)[1])
        expect(grid.getRow(2)[2]).toBe(grid.getCol(2)[2])
        expect(grid.getCol(1)[2]).toBe(grid.getCell(1, 2))
        expect(grid.getRow(2)[1]).toBe(grid.getCell(1, 2))


describe 'Calculate check', ->

    it 'connecting', ->

        blocks = [
            '''
            · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
            · · 0 · ·|· · · · ·|· 0 x · ·|· · · 0 ·|· x x x ·|· x x x ·
            · · 0 · ·|· 0 0 · ·|· · x · ·|· x x x ·|· 0 · 0 ·|· x · x ·
            · · · · ·|· · · · ·|· · x 0 ·|· 0 · · ·|· · · · ·|· 0 · 0 ·
            · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
            '''
        ]

        for row in blocks
            for block in separate row
                expect(block).connecting()

    it 'not connecting', ->

        blocks = [
            '''
            · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
            · · 0 · ·|· · · · ·|· x · x ·|· 0 x · ·|· 0 · · ·|· 0 · x ·
            · · · · ·|· 0 · 0 ·|· 0 · 0 ·|· · · · ·|· x · x ·|· x · x ·
            · · 0 · ·|· · · · ·|· · · · ·|· · x 0 ·|· · · 0 ·|· x · 0 ·
            · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
            '''
        ]

        for row in blocks
            for block in separate row
                expect(block).not.connecting()


    [BLOCK, TARGET, PATH, SPACE, SEPARATOR, NEWLINE] = '·0x |\n'.split('')

    separate = (blocks) ->

        matrix = for row in blocks.split NEWLINE
            row.split SEPARATOR

        [width, height] = [matrix[0].length, matrix.length]

        blocks = for i in [0...width]
            block = for j in [0...height]
                matrix[j][i]
            block.join NEWLINE

    beforeEach ->

        @addMatchers

            connecting: ->

                matrix = for row in @actual.split NEWLINE
                    row.split SPACE

                [width, height] = [matrix.length, matrix[0].length]

                targets = []
                grid = new GridModel width, height, CellModel
                calulate = new Calculate grid

                for x in [0...height]
                    for y in [0...width]
                        char = matrix[y][x]

                        cell = grid.getCell x, y
                        cell.add new State char is PATH
                        cell.add new Point x, y
                        cell.add new Range

                        targets.push cell if char is TARGET

                for target in targets
                    point = target.get Point
                    range = target.get Range
                    row = grid.getRow point.y
                    col = grid.getCol point.x

                    for i in [point.x - 1..0]
                        break unless row[i]?.get(State).done
                        range.left++

                    for i in [point.x + 1...row.length]
                        break unless row[i]?.get(State).done
                        range.right++

                    for i in [point.y - 1..0]
                        break unless col[i]?.get(State).done
                        range.top++

                    for i in [point.y + 1...col.length]
                        break unless col[i]?.get(State).done
                        range.bottom++

                calulate.hasMatch targets...
