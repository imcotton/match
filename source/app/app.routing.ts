
import { ModuleWithProviders, Type }  from '@angular/core';
import { Route, RouterModule } from '@angular/router';


import { PlayComponent, BoardComponent } from './play/play.component'
import { LeaderboardComponent } from './leaderboard/leaderboard.component'





export const ROUTING = RouterModule.forRoot(<Route[]>[
    {
        path: '',
        pathMatch: 'full',
        component: PlayComponent,
    },

    {
        path: 'leaderboard',
        pathMatch: 'full',
        component: LeaderboardComponent,
    },
]);



export const declarations = [
    PlayComponent,
        BoardComponent,

    LeaderboardComponent,
];

