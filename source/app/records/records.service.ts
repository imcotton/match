
import { Injectable } from '@angular/core';


import { Observable } from 'rxjs/Observable';
import { ReplaySubject } from 'rxjs/ReplaySubject';


import { Records } from './records.component';


import localForage from 'localforage';





@Injectable()
export class RecordsService {

    static readonly MAX_RECORD_SIZE = 42;


    constructor (
    ) {
        this.store.config({
            name: 'Leaderboard',
            storeName: 'record',
        });

        this.store.setDriver([
            localForage.INDEXEDDB,
            localForage.LOCALSTORAGE,
        ]);
    }


    private store = localForage;


    getSource (size = RecordsService.MAX_RECORD_SIZE) {
        return Observable
            .fromPromise(
                this.store
                    .getItem<string[]>('score')
                    .then(list => list || [])
            )
            .flatMap(list => list.map(n => new Record().decode(n)))
            .take(size)
        ;
    }

    addRecord (time: number, width: number, height: number) {
        const THIS = RecordsService;
        const record = new Record(time, width, height);

        return this.getSource()
            .startWith(record)
            .map(item => item.encode())
            .toArray()
            .do(list => {
                list.length = Math.min(THIS.MAX_RECORD_SIZE, list.length);
                this.store.setItem('score', list);
            })
            .toPromise()
        ;
    }
}



class Record implements Records.Record {

    private static readonly DOT = '::';

    private static sizeGen = (function (cache) {
        return function (width: number, height: number) {
            const key = `${ width }x${ height }`;

            return cache[key] = cache[key] || {
                width,
                height,
            };
        }
    }(<{[key: string]: Records.Size;}>{}));


    constructor (
        public time = NaN,
        width = 0,
        height = 0,
    ) {
        this.date = new Date();
        this._size = Record.sizeGen(width, height);
    }


    date: Date;

    private _size: {width: number; height: number;};
    get size () {
        return this._size as Records.Size;
    }


    encode () {
        return [
            this.time,
            this.size.width,
            this.size.height,
            this.date.valueOf(),

        ].join(Record.DOT);
    }

    decode = (source: string) => {
        let timestamp = -1;

        [
            this.time,
            this._size.width,
            this._size.height,
            timestamp

        ] = source.split(Record.DOT).map(n => +n);

        this.date = new Date(timestamp);
        this._size = Record.sizeGen(this.size.width, this.size.height);

        return this;
    };
}

