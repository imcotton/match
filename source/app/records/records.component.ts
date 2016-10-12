
import {
    Component,

    OnInit,
    OnDestroy,

    ChangeDetectionStrategy,
    ChangeDetectorRef,
} from '@angular/core';


import { Title } from '@angular/platform-browser';


import { RecordsService } from './records.service';





@Component({
    selector: 'records',
    templateUrl: 'records.component.html',
    styleUrls: ['records.component.css'],
    providers: [
        RecordsService,
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RecordsComponent implements OnInit, OnDestroy {

    constructor (
        private title: Title,
        private recordsService: RecordsService,
    ) {
        this.title.setTitle('Records');
    }


    records = this.recordsService.getSource().toArray().toPromise();


    ngOnInit () {
    }

    ngOnDestroy () {
    }

}



export namespace Records {

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

