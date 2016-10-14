
export { Bucket } from './bucket'
export { Stopwatch } from './stopwatch'





export const shuffle = function <T>(list: T[]) {
    list = list.concat();

    for (let j = 0, i = list.length - 1; i > 0; i--) {
        j = ~~(Math.random() * (i + 1));
        [list[i], list[j]] = [list[j], list[i]];
    }

    return list;
}



export const noop = function () {};

