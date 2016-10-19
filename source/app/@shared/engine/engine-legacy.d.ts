
import { Range, CellModel, GridModel } from './engine';





export declare class Calculator {

    constructor (grid: GridModel<CellModel>)

    hasMatch (foo: CellModel, bar: CellModel): boolean

    markMatch (cell: CellModel): Calculator
}

