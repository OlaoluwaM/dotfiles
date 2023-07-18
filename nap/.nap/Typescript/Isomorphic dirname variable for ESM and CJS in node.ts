import { dirname } from 'path'
import { fileURLToPath } from 'url'

// Context: When you need to compile your Node code to support both CJS and ESM, 
// and the value of the `__dirname` variable is needed

// Trick Node to evaluate whether or not we are in a CJS module using `typeof __dirname === 'undefined'`. 
// Doing so in this way is crucial because we circumvent the direct evaluation of `__dirname` 
// which will cause an error (without the full evaluation of the conditional) if performed in an ESM setting. 

// https://antfu.me/posts/isomorphic-dirname

// We use `typeof __dirname` instead of `__dirname ??` because we do not want Node to
// evaluate the meaning of `__dirname` when it is not in a CJS module as doing so will cause Node
// to error out without actually evaluating the conditional expression

const _dirname = typeof __dirname !== 'undefined'
  ? __dirname
  : dirname(fileURLToPath(import.meta.url))
