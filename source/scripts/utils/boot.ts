
import { Observable } from 'rxjs/Observable';





export const ready = (function (window) {
    return Observable
        .interval(0x42)
        .take(0x998)
        .first(
            v => 'Zone' in window,
            v => true,
            false,
        )
    ;
}(window || {}));

