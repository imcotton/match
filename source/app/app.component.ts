
import { Component, Version, VERSION as ngVer } from '@angular/core';





@Component({
    selector: 'app',
    templateUrl: 'app.component.html',
    styleUrls: ['app.component.css'],
})
export class AppComponent {

    appVersion = new Version('1.0.0-rc.4').full;
    ngVersion = ngVer.full;

}

