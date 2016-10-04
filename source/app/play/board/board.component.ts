
import {
    Component,
    SimpleChange,
    SimpleChanges,

    OnInit,
    OnDestroy,
    OnChanges,

    Input,
    Output,

    ChangeDetectionStrategy,
    ChangeDetectorRef,
} from '@angular/core';


import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';


import { Bucket, StopWatch } from '../../@shared/helper';





@Component({
    selector: 'board',
    templateUrl: 'board.component.html',
    styleUrls: ['board.component.css'],
    providers: [
        Bucket,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BoardComponent implements OnInit, OnDestroy, OnChanges {

    @Input() grid: Promise<Board.ItemList[]>;
    @Input() renderObs: Observable<Board.Pair>;
    @Input() autoplayObs: Observable<boolean>;

    @Output() pairObs: Observable<Board.Pair>;

    constructor (
        private cdr: ChangeDetectorRef,
        private bucket: Bucket,
        private stopWatch: StopWatch,
    ) {
        this.pairObs = this.grouping
            .filter(([last, current]) =>
                   !last.pseudo
                && last.done === false
                && last.color === current.color
            )
            .map(([bob, alice]) => <Board.Pair>{bob, alice})
            .share()
        ;
    }


    autoPlayOn = false;
    picker = new Subject<Board.Item>();

    private grouping = this.picker
        .filter(item => this.autoPlayOn === false)
        .filter(item => !item.done)
        .distinctUntilChanged()
        .pairwise()
        .share()
    ;


    ngOnInit () {
        this.bucket

            .add(
                this.renderObs.subscribe(({bob, alice}) => {
                    this.cdr.markForCheck();
                })
            )

            .add(
                this.grouping
                    .subscribe(([last, current]) => {
                        last.selected = false;
                        current.selected = true;

                        if (!current.pseudo) {
                            this.stopWatch.start();
                        }
                    })
            )

            .add(
                this.autoplayObs.subscribe(auto => {
                    this.autoPlayOn = auto;
                    this.cdr.markForCheck();
                })
            )
        ;
    }

    ngOnChanges (changes: SimpleChanges) {
        Object.entries<SimpleChange>(changes).forEach(([key, change]) => {
            if (key === 'grid' && !!change.currentValue) {
                let item = <Board.Item>{};
                    item.pseudo = true;

                this.picker.next(item);
            }
        });
    }

    ngOnDestroy () {
        this.bucket.release();
    }
}



export namespace Board {

    export interface Item {

        readonly done: boolean
        readonly index: number

        readonly point: {
            readonly x: number
            readonly y: number
        }

        readonly color: Color

        selected?: boolean
        pseudo?: boolean
    }

    export type ItemList = Item[]

    export interface Color {
        readonly hex: number
        readonly hexString: string
    }

    export interface Pair {
        readonly bob: Item
        readonly alice: Item
    }
}

