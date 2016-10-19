
export const add = function (a = 0, b = 0) {
    return a + b;
};



export const average = function (list: number[]) {
    return list.reduce(add) / list.length;
};



export const std = function (list: number[]) {
    const avg = average(list);

    return Math.sqrt(
        average(
            list
                .map(i => i - avg)
                .map(d => d * d)
        )
    );
};



export const factorial = (function (cache: {[key: number]: number}) {
    return function (n: number): number {
        if (n in cache) {
            return cache[n];
        }

        return cache[n] = n * factorial(n - 1);
    }
}({0: 1, 1: 1}));

