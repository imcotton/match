
import {
    Component,

    OnInit,
    OnDestroy,
    OnChanges,

    Pipe,
    PipeTransform,

    ChangeDetectionStrategy,
    ChangeDetectorRef,
} from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';

import { Title } from '@angular/platform-browser';


import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';


import { Bucket, Stopwatch } from '../@shared/helper';

import { BoardComponent, Board } from './board/board.component';

import { PlayService } from './play.service';

import { RecordsService } from '../records/records.service';





@Component({
    selector: 'play',
    templateUrl: 'play.component.html',
    styleUrls: ['play.component.css'],
    providers: [
        PlayService,
        RecordsService,
        Bucket,
        Stopwatch,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PlayComponent implements OnInit, OnDestroy {

    constructor (
        private title: Title,
        private cdr: ChangeDetectorRef,
        private bucket: Bucket,
        private router: Router,
        private activated: ActivatedRoute,
        private playService: PlayService,
        private recordsService: RecordsService,
        private stopwatch: Stopwatch,
    ) {
        this.title.setTitle('Play');
    }


    nextPair?: Board.Pair;

    renderSubject = new Subject<Board.Pair>();
    autoplaySubject = new BehaviorSubject(false);

    hint = 0;
    timer = {h: 0, m: 0, s: 0};

    source?: {
        data: Promise<Board.ItemList[]>;
        checking: (pair: Board.Pair) => boolean;
        marking: (...item: Board.ItemList) => void;
        nextPairObs: Observable<Board.Pair>;
    };


    private create (width = 1, height?: number) {
        height = height || width;

        this.source = this.playService.getSource(width, height);

        this.bucket.add(
            this.source
                .nextPairObs
                .subscribe({
                    next: (pair) => {
                        this.nextPair = pair;
                    },
                    complete: () => {
                        this.nextPair = undefined;
                        this.stopwatch.stop();

                        if (   this.autoplaySubject.value === true
                            || this.stopwatch.time <= 0
                        ) {
                            return;
                        }

                        this.recordsService
                            .addRecord(this.stopwatch.time, width, height!)
                        ;
                    },
                })
        );

        this.hint = 3;
        this.stopwatch.reset();
        this.autoplaySubject.next(false);
    }

    private crossPair = (pair: Board.Pair) => {
        this.onPair(pair, true);
        this.renderSubject.next(pair);
    };

    ngOnInit () {
        this.bucket

            .add(
                this.activated
                    .queryParams
                    .subscribe(({w = 7, h}: Params) => {
                        this.create(+w, +(h || w));
                    })
            )

            .add(
                Observable
                    .interval(99)
                    .map(n => this.stopwatch.time)
                    .map(ms => ~~(ms / 1000))
                    .distinctUntilChanged()
                    .map(s => ({
                        h: ~~(s / 3600),
                        m: ~~(s % 3600 / 60),
                        s: ~~(s % 3600 % 60 + 0.5),
                    }))
                    .subscribe(timer => {
                        this.timer = timer;
                        this.cdr.markForCheck();
                    })
            )

            .add(
                this.autoplaySubject
                    .distinctUntilChanged()
                    .switchMap(auto =>
                        auto && !!this.nextPair
                        ? Observable.interval(400)
                        : Observable.never()
                    )
                    .map(n => this.nextPair!)
                    .filter(pair => !!pair)
                    .subscribe(this.crossPair)
            )
        ;
    }

    onPair (pair: Board.Pair, skipChecks = false) {
        let connected = true;

        if (skipChecks === false) {
            connected = this.source!.checking(pair);
        }

        if (connected === false) return;

        this.source!.marking(pair.bob, pair.alice);
    }

    onHint (validated: Board.Pair) {
        this.hint--;
        this.stopwatch.start();

        this.crossPair(validated);
    }

    onAutoplay ($event: Event) {
        this.stopwatch.stop();
        this.autoplaySubject.next(true);
    }

    onReplay ($event: Event) {
        window.location.reload();
    }

    ngOnDestroy () {
        this.bucket.release();
    }
}



@Pipe({
    name: 'repeat',
})
export class RepeatPipe implements PipeTransform {

    transform (amount: number, ingredient = '') {
        return Array(amount + 1).join(ingredient);
    }
}



export { BoardComponent }

