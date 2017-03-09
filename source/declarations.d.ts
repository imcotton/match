
declare module '*!text' {
    const text: string;
    export default text;
}



declare module '../codegen/*';



declare module '*/package.json' {

    const package: {
        name: string;
        version: string;
    };

    export const {
        name,
        version

    } = package;

    export default package;
}



interface IterableIterator<T> extends ArrayLike<T> {
}



interface String {
    padStart (targetLength: number, padString: string): string
    padEnd (targetLength: number, padString: string): string
}

