
import 'reflect-metadata';
import './utils/rxjs-operators';


import { enableProdMode } from '@angular/core';
import { platformBrowser } from '@angular/platform-browser';


import { AppModuleNgFactory } from '../codegen/app/app.module.ngfactory';
import { ready } from './utils/boot';





ready.subscribe(good => {
    if (!good) return;

    enableProdMode();
    platformBrowser().bootstrapModuleFactory(AppModuleNgFactory);
});

