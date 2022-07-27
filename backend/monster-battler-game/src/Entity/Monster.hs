module Entity.Monster where

import Components.Component

data Monster = Monster {} deriving Show
instance Component Monster where
	update monster _ = monster

