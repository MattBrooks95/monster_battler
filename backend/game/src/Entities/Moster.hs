module Entity.Monster where

import Components.Health

data Moster = Monster { hpBars :: [HealthComponent] } deriving Show
