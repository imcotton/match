
import { Injectable } from '@angular/core';


import { AnonymousSubscription } from 'rxjs/Subscription';





@Injectable()
export class Bucket {

    private subscriptions = new Set<AnonymousSubscription>();

    add = (subscription: AnonymousSubscription) => {
        this.subscriptions.add(subscription);
        return this;
    };

    release = () => {
        this.subscriptions.forEach(item => item.unsubscribe());
        this.subscriptions.clear();
    };
}

