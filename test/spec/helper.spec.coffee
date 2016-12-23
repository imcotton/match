
{
    Bucket,
    Stopwatch,

    math, shuffle, noop,

} = require '../../dist/app/@shared'


_ = require 'lodash/fp'





describe 'Utils: shuffle', ->

    before = after = undefined


    beforeEach ->

        before = _.range 0, 5
        after = shuffle before


    it 'Shuffles', ->

        expect(after.length).toBe(before.length)
        expect(after).toEqual(jasmine.arrayContaining before)


    it 'In range of standard deviation', ->

        sum = {}
        cycle = _.range 0, before.length * 100000

        cycle.forEach ->
            key = shuffle(before).join '-'
            sum[key] = 1 + (sum[key] or 0)

        exp = Math.sqrt cycle.length * 1 / math.factorial before.length
        std = math.std _.values sum

        expect(std)    .toBeGreaterThan(exp * 0.85)
        expect(std).not.toBeGreaterThan(exp * 1.15)



describe 'Utils: math', ->

    it 'Add', ->

        expect(math.add(4, 2)).toBe(6)


    it 'Average', ->

        expect(math.average([1, 3, 5, 7, 9])).toBe(5)


    it 'Factorial', ->

        expect(math.factorial(0)).toBe(1)
        expect(math.factorial(1)).toBe(1)
        expect(math.factorial(2)).toBe(2)
        expect(math.factorial(3)).toBe(6)
        expect(math.factorial(4)).toBe(24)
        expect(math.factorial(5)).toBe(120)


    it 'Standard deviation', ->

        expect(math.std([2, 4, 4, 4, 5, 5, 7, 9])).toBe(2)

