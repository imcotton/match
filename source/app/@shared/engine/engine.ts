
export class State {

    constructor (public done = false) {
    }
}



export class Point {

    constructor (public x = 0, public y = 0) {
    }

    toString () {
        return `(${ this.x }, ${ this.y })`;
    }
}



export class Range {

    constructor (
        public top = 0,
        public bottom = 0,
        public left = 0,
        public right = 0,
    ) {
    }

    get unitX () {
        return this.left + this.right + 1;
    }

    get unitY () {
        return this.top + this.bottom + 1;
    }

    markX (offset: number) {
        return ((1 << this.unitX) - 1) << offset - this.left;
    }

    markY (offset: number) {
        return ((1 << this.unitY) - 1) << offset - this.top;
    }
}



export class CellModel {

    private typeHash = new WeakMap<Function, Object>();

    add = <T>(instance: T) => {
        this.typeHash.set(instance.constructor, instance);
        return instance;
    };

    get = <T>(clazz: {new(...arg: any[]): T;}) => {
        const instance = this.typeHash.get(clazz);

        if (instance && instance instanceof clazz) {
            return instance;
        }

        return undefined;
    };
}



export class GridModel<T> {

    constructor (width = 0, height = 0, Base: {new(): T;}) {

        for (let i = 0; i < height; i++) {
            this.row[i] = [];

            for (let j = 0; j < width; j++) {
                this.row[i][j] = new Base();
            }
        }

        for (let i = 0; i < width; i++) {
            this.col[i] = [];

            for (let j = 0; j < height; j++) {
                this.col[i][j] = this.row[j][i];
            }
        }
    }

    get height () { return this.row.length; }
    get width () { return this.col.length; }

    private row: Array<T[]> = [];
    private col: Array<T[]> = [];

    getRow (index: number) {
        return this.row[index];
    }

    getCol (index: number) {
        return this.col[index];
    }

    getCell (x: number, y: number) {
        var inside = true;

        if (x < 0 || x >= this.width) inside = false;
        if (y < 0 || y >= this.height) inside = false;

        return inside ? this.getRow(y)[x] : undefined;
    }
}

