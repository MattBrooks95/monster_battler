module Entity.Monster where

import Components.Health

data Monster = Monster { components :: [Component] } deriving Show
