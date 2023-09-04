type Prettify<Obj> = { [K in keyof Obj]: Prettify<Obj[K]> } | never

type Overwrite<T, U> = U extends object ? (
    { [K in keyof T]: K extends keyof U ? Overwrite<T[K], U[K]> : T[K] }
) : U

type Foo = {
    a: {
        b: {
            c: string[];
            d: number;
        }
        e: {
            f: boolean;
        }
    };
    g: {
        h?: () => string;
    }
}

type ReplaceFoo = Overwrite<Foo, { a: { b: { c: number } } }>;
//    ^?


type Bar = Prettify<Foo & { a: { b: { c: number } } }
//   ^?
