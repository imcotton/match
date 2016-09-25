
import {
    Component,
    SimpleChanges,

    OnInit,
    OnDestroy,
    OnChanges,

    ChangeDetectionStrategy,
    ChangeDetectorRef,
} from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';

import { Title } from '@angular/platform-browser';


import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';


import { Bucket } from '../@shared/helper';

import { BoardComponent, Board } from './board/board.component';

import { PlayService } from './play.service';





@Component({
    selector: 'play',
    templateUrl: 'play.component.html',
    styleUrls: ['play.component.css'],
    providers: [
        PlayService,
        Bucket,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PlayComponent implements OnInit, OnDestroy, OnChanges {

    constructor (
        private title: Title,
        private cdr: ChangeDetectorRef,
        private bucket: Bucket,
        private router: Router,
        private activated: ActivatedRoute,
        private playService: PlayService,
    ) {
        this.title.setTitle('Play');
    }


    nextPair?: Board.Pair;
    renderSubject = new Subject<Board.Pair>();

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
                    },
                })
        );
    }

    ngOnInit () {
        this.bucket.add(
            this.activated
                .queryParams
                .subscribe(({w = 7, h}: Params) => {
                    this.create(+w, +(h || w));
                })
        );
    }

    onPair (pair: Board.Pair, skipChecks = false) {
        let connected = true;

        if (!skipChecks) {
            connected = this.source!.checking(pair);
        }

        if (!connected) return;

        this.source!.marking(pair.bob, pair.alice);
    }

    onHint (validated: Board.Pair) {
        this.onPair(validated, true);
        this.renderSubject.next(validated);
    }

    onReplay ($event: MouseEvent) {
        window.location.reload();
    }

    ngOnChanges (simpleChanges: SimpleChanges) {
    }

    ngOnDestroy () {
        this.bucket.release();
    }
}



export { BoardComponent }

