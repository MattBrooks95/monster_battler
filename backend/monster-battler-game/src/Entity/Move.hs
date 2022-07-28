module Entity.Move where

type UsageCount = Int

data Effect = Effect deriving Show

data Move = Move {
	-- number of times a move can be used within a match
	usageLimit::UsageCount,
	-- number of uses remaining for this move this match
	usages::UsageCount,
	-- list of effects of the move (chance to freeze, dealing damage, causing weather...)
	effects::[Effect]
} deriving Show
