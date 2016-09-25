
import { Injectable } from '@angular/core';


import { Subscription } from 'rxjs/Subscription';





@Injectable()
export class Bucket {

    private subscriptions = new Set<Subscription>();

    add = (subscription: Subscription) => {
        this.subscriptions.add(subscription);
        return this;
    };

    release = () => {
        this.subscriptions.forEach(item => item.unsubscribe());
        this.subscriptions.clear();
    };
}

