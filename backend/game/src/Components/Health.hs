module Components.Health where

import Components.Component

import Primitives.Combat (Damage(..), Healing(..))

data HealthComponent = HealthComponent { health :: Int } deriving Show
instance Component HealthComponent

-- createMove :: Int -> Int -> Player -> Move
-- createMove rowNumber columnNumber player = (Move {rowNumber=rowNumber, columnNumber=columnNumber, player=player})

subHealth :: HealthComponent -> Damage -> HealthComponent
subHealth originalHealth damage = HealthComponent { health = newHealth }
	where newHealth = health originalHealth - damage

addHealth :: HealthComponent -> Healing -> HealthComponent
addHealth originalHealth healing = HealthComponent { health = newHealth }
	where newHealth = health originalHealth + healing

