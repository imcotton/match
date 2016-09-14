
    {
        State, Point, Range,
        CellModel, GridModel, Calculator

    } = require '../../dist/app/@shared/engin/index.umd'


    describe 'loading modules', ->

        list = {State, Point, Range, CellModel, GridModel, Calculator}

        for key, value of list
            do (key, value) ->
                it "has component: #{key}", ->
                    expect(value).toBeDefined()


    describe 'components init check', ->

        state = point = range = grid = null

        beforeEach ->

            [state, point, range, grid] = [
                new State true
                new Point 3, 5
                new Range 2, 3, 4, 5
                new GridModel 3, 5, Array
            ]

        it 'State', ->
            expect(state.done).toBeTruthy()

        it 'Point', ->
            expect(point.toString()).toEqual('(3, 5)')

        it 'Range', ->
            expect(range.unitX).toBe(10)
            expect(range.unitY).toBe(6)
            expect(range.markX(4)).toBe(0b1111111111)
            expect(range.markX(5)).toBe(0b11111111110)
            expect(range.markX(6)).toBe(0b111111111100)
            expect(range.markY(2)).toBe(0b111111)
            expect(range.markY(6)).toBe(0b1111110000)

        it 'CellModel', ->
            list =
                clazz:    [State, Point, Range]
                instance: [state, point, range]

            cellModel = new CellModel()
            cellModel.add i for i in list.instance

            item = list.clazz.map (item) -> cellModel.get item

            for i in [0...list.clazz.length]
                expect(cellModel.get(list.clazz[i])).toBe(list.instance[i])

            for i in item
                expect(i in list.instance).toBeTruthy()

        it 'GridModel', ->
            expect(grid.getCell(0, 0)).toEqual(jasmine.any(Array))
            expect(grid.width).toBe(3)
            expect(grid.height).toBe(5)
            expect(grid.getRow(1)[2]).toBe(grid.getCol(2)[1])
            expect(grid.getRow(2)[2]).toBe(grid.getCol(2)[2])
            expect(grid.getCol(1)[2]).toBe(grid.getCell(1, 2))
            expect(grid.getRow(2)[1]).toBe(grid.getCell(1, 2))

#### Here are some handy `inline` map samples for easy testing purpose

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
                '''
                0 · · · 0|· · · · ·|0 · · · ·|· · · · 0|· 0 · 0 ·|· · · · ·
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · ·
                · · · · ·|0 · · · 0|0 · · · ·|· · · · 0|· · · · ·|· 0 · 0 ·
                '''
                '''
                · 0 · x ·|· x · x ·|· · · · ·|· · · · ·|0 x x · ·|· · · · ·
                · · · x ·|· 0 · x ·|0 · · · ·|x x 0 · ·|· · x · ·|· · · 0 x
                · · · x ·|· · · x ·|· · · · ·|· · · · ·|· · x · ·|· · · · ·
                · · · 0 ·|· · · 0 ·|x x 0 · ·|x x 0 · ·|· · x · ·|· 0 x x x
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · x x 0|· · · · ·
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
                '''
                0 · · · ·|· · · · 0|· · · · ·|· · 0 · ·|· · · · 0|· · x · ·
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|· · · · x|· · 0 · ·
                · · · · ·|· · · · ·|0 · · · 0|· · · · ·|x x · x x|· · · · ·
                · · · · ·|· · · · ·|· · · · ·|· · · · ·|x · · · ·|· · 0 · ·
                · · · · 0|0 · · · ·|· · · · ·|· · 0 · ·|0 · · · ·|· · x · ·
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

            jasmine.addMatchers

                connecting: ->
                    compare: (actual) ->

                        matrix = for row in actual.split NEWLINE
                            row.split SPACE

                        [width, height] = [matrix.length, matrix[0].length]

                        targets = []
                        grid = new GridModel width, height, CellModel
                        calculator = new Calculator grid

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

                        pass = calculator.hasMatch targets...
                        result = ['connected', 'not connected'][+pass]

                        {
                            pass: pass
                            message: "Expected below to be #{result} \n#{actual}"
                        }
