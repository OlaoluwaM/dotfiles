

// Context: When you want to ensure that a type strictly matches a given shape with no excesses or omissions
// https://github.com/microsoft/TypeScript/issues/12936
// https://fettblog.eu/typescript-match-the-exact-object-shape/

// Playground Link: https://www.typescriptlang.org/play?#code/C4TwDgpgBAChBOBnA9gOygXigbwLACgooAzASyWAC4pFh5TUBzAGigBsBDW62+pggL4ECoSFABqHNqQAmHYBADKdAK4BjYCvgQAPABVWy+OuAA+TFAJE9UCAA8FqGYihGTUAPyXCUAKJ21NhUZXQBrCBBkYigDKHDI6LcNc3tHZyhUCAA3BE8YqGpMnPgCjOyEAG5hfBDAjm0SFVQNUjQaDhy4JDR9UwAKSG7UaklpOQUkzW19Vi6UVFMASmos5Fkq-AI1NFooYGRkADEIAHcLbBJybigAcmUIYg5UG6gBDe3UXfsODXPLimodwUj2erE41xuACEOCoALaMerATLwF5CfAfXb7ZAAWSeID+ZABt3uIJuYK4VFu0LhCPgSIQZKgHEYEGoAGYAOyvaqIDoQOZoPpY44nRYVKAAeglUEAvBuAUp2oDJkBBEM9gFATsh4KECLzOgh5n1vhoxZLpYBQcnawFIiDIKr2AAtoB86D9gLq+QLUEKDrjUCBTVLZQqlSq1RqtTrNvggA


/*
  Here is how it works. It first establishes whether the type passed as argument to `T` and the type passed 
  as argument to `Shape` are compatible: `T extends Shape`. 

  Then it checks whether `T` has any properties not explicitly defined on the desired `Shape` 
  (`Exclude<keyof T, keyof Shape>`) by excluding all of the keys from the desired 
  `Shape` interface from those on the `T` type. If `T` had only the required keys, 
  then the exclusion operation would yield a `never` type. 

  Otherwise it would yield a union of **excess** keys present on the `T` type. 
  If the exclusion operation yielded a `never` type, 
  then we know `T` matches the structure of the `Shape` type strictly and we can return it. 
  If otherwise, then we know `T` contains excess properties so we must return `never`
*/

type ValidateShape<T, Shape> =
  T extends Shape 
    ? Exclude<keyof T, keyof Shape> extends never 
      ?  T 
      : never 
    : never;
