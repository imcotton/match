
import { Component, Version, VERSION as ngVer } from '@angular/core';


import { version as appVer } from '../../package.json';





@Component({
    selector: 'app',
    templateUrl: 'app.component.html',
    styleUrls: ['app.component.css'],
})
export class AppComponent {

    appVersion = new Version(appVer).full;
    ngVersion = ngVer.full;

}

