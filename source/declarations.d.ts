
declare module '*!text' {
    const text: string;
    export default text;
}



declare module '../codegen/*';



interface IterableIterator<T> extends ArrayLike<T> {
}



interface String {
    padStart (targetLength: number, padString: string): string
    padEnd (targetLength: number, padString: string): string
}

