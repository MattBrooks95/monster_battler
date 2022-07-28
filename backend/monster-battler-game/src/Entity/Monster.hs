module Entity.Monster where

import Components.Component
import Entity.Move (
		Move(..)
	)

data Monster = Monster {
	moves::[Move]
} deriving Show

instance Component Monster where
	update monster _ = monster

