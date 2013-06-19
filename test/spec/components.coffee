{
    State, Point, Range, Color
    CellModel, GridModel, Calculate
} = components


describe 'loading modules', ->

    list = {
        State, Point, Range, Color
        CellModel, GridModel, Calculate
    }

    for key, value of list
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
