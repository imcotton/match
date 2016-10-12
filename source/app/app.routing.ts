
import { ModuleWithProviders, Type }  from '@angular/core';
import { Route, RouterModule } from '@angular/router';


import { PlayComponent, BoardComponent, RepeatPipe } from './play/play.component'
import { RecordsComponent } from './records/records.component'





export const ROUTING = RouterModule.forRoot(<Route[]>[
    {
        path: '',
        pathMatch: 'full',
        component: PlayComponent,
    },

    {
        path: 'records',
        pathMatch: 'full',
        component: RecordsComponent,
    },
]);



export const declarations = [
    PlayComponent, RepeatPipe,
        BoardComponent,

    RecordsComponent,
];

