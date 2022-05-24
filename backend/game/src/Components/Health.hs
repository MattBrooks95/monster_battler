module Components.Health where

import Primitives.Combat (Damage(..))

data HealthComponent = HealthComponent { health :: Int } deriving Show

-- createMove :: Int -> Int -> Player -> Move
-- createMove rowNumber columnNumber player = (Move {rowNumber=rowNumber, columnNumber=columnNumber, player=player})

subHealth :: HealthComponent -> Damage -> HealthComponent
subHealth originalHealth damage = HealthComponent { health = newHealth }
	where newHealth = health originalHealth - damage
