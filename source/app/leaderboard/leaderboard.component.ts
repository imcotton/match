
import {
    Component,

    OnInit,
    OnDestroy,

    ChangeDetectionStrategy,
    ChangeDetectorRef,
} from '@angular/core';


import { Title } from '@angular/platform-browser';


import { LeaderboardService } from './leaderboard.service';





@Component({
    selector: 'leaderboard',
    templateUrl: 'leaderboard.component.html',
    styleUrls: ['leaderboard.component.css'],
    providers: [
        LeaderboardService,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LeaderboardComponent implements OnInit, OnDestroy {

    constructor (
        private title: Title,
        private leaderboardService: LeaderboardService,
    ) {
        this.title.setTitle('Leaderboard');
    }


    records = this.leaderboardService.getSource().toArray().toPromise();


    ngOnInit () {
    }

    ngOnDestroy () {
    }

}



export namespace Leaderboard {

    export interface Record extends Serializable {
        readonly time: number
        readonly date: Date
        readonly size: Size
    }

    export interface Size {
        readonly width: number
        readonly height: number
    }

    export interface Serializable {
        encode (): string
        decode <T>(source: string): T
    }
}

