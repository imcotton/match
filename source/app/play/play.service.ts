
import { Injectable } from '@angular/core';


import { Observable } from 'rxjs/Observable';
import { ReplaySubject } from 'rxjs/ReplaySubject';


import { State, Point, Range, CellModel, GridModel, Calculator } from '../@shared/engine';

import { shuffle } from '../@shared/helper';

import { Board } from './board/board.component';






@Injectable()
export class PlayService {

    private static hexStore = [
        0x356B8A,
        0xC84663,
        0x62B422,
        0xFF9666,
        0xF0EDBB,
    ];

    constructor (
    ) {
    }

    private *genHex (count = 0) {

        const range = Array.from(Array(count), (n, i) => i);
        const indexs = shuffle(range);

        while (indexs.length) {
            yield PlayService.hexStore[
                indexs.pop() % PlayService.hexStore.length
            ];
        }

        return 0xFFFFFF;
    }

    getSource (this: PlayService, width = 1, height = 1, delay = 400) {

        const grid = new GridModel(width, height, CellModel);
        const calculator = new Calculator(grid);

        const cache = new WeakMap<Board.Item, CellModel>();
        const unpack = (item: Board.Item) => cache.get(item) as CellModel;

        const checking = ({bob, alice}: Board.Pair) =>
            calculator.hasMatch(unpack(bob), unpack(alice));

        const boardItemList: Board.ItemList = [];

        Observable
            .range(0, width * height)
            .zip(Observable.from(this.genHex(width * height)))
            .map(([index, color]: [number, number]) => {

                const [x, y] = [index % width, ~~(index / width)];

                const cellModel = grid.getCell(x, y) as CellModel;
                      cellModel.add(new Range());

                const item: Board.Item = new BoardItem(
                    cellModel.add(new State()),
                    cellModel.add(new Point(x, y)),
                    index,
                    color,
                );

                cache.set(item, cellModel);

                return item;
            })
            .toArray()
            .subscribe(list => boardItemList.push(...list))
        ;

        type ColorGroup = {
            [key: number]: Board.ItemList;
        };

        const groupByColor = <ColorGroup>{};

        Observable
            .from(boardItemList)
            .groupBy(item => item.color)
            .subscribe(group => {
                group.toArray().subscribe(list => {
                    groupByColor[group.key.hex] = list;
                });
            })
        ;

        const genNextPair = (function (store: ColorGroup, list?: Board.ItemList) {
            return function () {
                for (let key in store) {
                    list = store[key];

                    for (let i = 0, j = 0; i < list.length - 1; i++) {
                        if (list[i].done) continue;

                        for (j = i + 1; j < list.length; j++) {
                            if (list[j].done) continue;

                            if (checking({bob: list[i], alice: list[j]})) {
                                return <Board.Pair>{
                                    bob: list[i],
                                    alice: list[j],
                                };
                            }
                        }
                    }
                }

                return undefined;
            };
        }(groupByColor));

        const nextPair = new ReplaySubject<Board.Pair>();

        const supplyNextPair = (function (subject, gen) {
            return function (pair = gen()) {
                if (pair) {
                    subject.next(pair);
                } else {
                    subject.complete();
                }
            };
        }(nextPair, genNextPair));

        supplyNextPair();


        return {
            data: Observable
                      .from(boardItemList)
                      .delay(delay)
                      .bufferCount(width)
                      .toArray()
                      .toPromise(),

            checking,

            marking (...items: Board.ItemList) {
                items.forEach(item => calculator.markMatch(unpack(item)));
                supplyNextPair();
            },

            nextPairObs: nextPair.share(),
        };
    }
}



class BoardItem implements Board.Item {

    private static colorGen = (function (cache) {
        return function (hex: number) {
            return cache[hex] = cache[hex] || {
                hex,
                hexString: `#${ hex.toString(0x10) }`,
            };
        }
    }(<{[key: number]: Board.Color;}>{}));

    constructor (
        private state: State,
        public point: Point,
        public index = 0,
        hex: number,
    ) {
        this.color = BoardItem.colorGen(hex);
    }

    color: Board.Color;

    get done () {
        return this.state.done;
    }
}

