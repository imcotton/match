
import 'reflect-metadata';
import 'regenerator-runtime/runtime';
import './utils/rxjs-operators';


import { enableProdMode } from '@angular/core';
import { platformBrowser } from '@angular/platform-browser';


import { AppModuleNgFactory } from '../codegen/app/app.module.ngfactory';
import { ready } from './utils/boot';





ready

    .then(()=> {
        enableProdMode();
        platformBrowser().bootstrapModuleFactory(AppModuleNgFactory);
    })

    .catch(()=> {
        console.error('polyfills not present');
    })
;

