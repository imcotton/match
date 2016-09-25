
import { NgModule } from '@angular/core';
import { BrowserModule, Title } from '@angular/platform-browser';
import { HttpModule } from '@angular/http';


import { AppComponent } from './app.component';
import { ROUTING, declarations } from './app.routing';





@NgModule({
    bootstrap: [AppComponent],

    imports: [
        BrowserModule,
        HttpModule,

        ROUTING,
    ],

    providers: [
        Title,
    ],

    declarations: [
        AppComponent,

        ...declarations
    ],

})
export class AppModule {
}

