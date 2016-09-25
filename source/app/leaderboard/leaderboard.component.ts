
import {
    Component,

    OnInit,
    OnDestroy,

    SimpleChanges,
} from '@angular/core';


import { Title } from '@angular/platform-browser';





@Component({
    selector: 'leaderboard',
    templateUrl: 'leaderboard.component.html',
    styleUrls: ['leaderboard.component.css'],
    providers: [
    ],
})
export class LeaderboardComponent implements OnInit, OnDestroy {

    constructor (
        private title: Title,
    ) {
        this.title.setTitle('Leaderboard');
    }

    ngOnInit () {
    }

    ngOnDestroy () {
    }

}
































