module Entity.Monster where

import Components.Health

data Moster = Monster { components :: [Component] } deriving Show
