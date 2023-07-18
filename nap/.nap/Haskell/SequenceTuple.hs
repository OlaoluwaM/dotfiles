module SequenceTuple where

-- Courtesy: https://stackoverflow.com/questions/24913656/haskell-is-there-a-monad-sequence-function-for-tuples
import GHC.Base (liftM2)

sequenceTuple :: (Monad m) => (m a, m a) -> m (a, a)
sequenceTuple = uncurry $ liftM2 (,)
