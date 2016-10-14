
export class Stopwatch {

    private tape = {start: 0, stop: 0};

    private get now () {
        return Date.now();
    }

    get time () {
        const {start, stop} = this.tape;

        return (stop || this.now) - (start || this.now);
    }

    start = () => {
        if (this.tape.start > 0 === false) {
            this.tape.start = this.now;
        }

        if (this.tape.stop > 0) {
            this.tape.start = this.now - this.time;
            this.tape.stop = 0;
        }
    };

    stop = () => {
        if (this.tape.stop > 0) return;

        if (this.tape.start > 0 === false) {
            this.start();
        }

        this.tape.stop = this.now;
    };

    reset = () => {
        this.tape.start = this.tape.stop = 0;
    };
}

