
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



export const shuffle = function <T>(list: T[]) {
    list = list.concat();

    for (let j = 0, i = list.length - 1; i > 0; i--) {
        j = ~~(Math.random() * (i + 1));
        [list[i], list[j]] = [list[j], list[i]];
    }

    return list;
}

