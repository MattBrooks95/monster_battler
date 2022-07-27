module Game.Player where
import Entity.Monster

data Player = Player {
	monsters :: [Monster],
	--uniq id for this player within this game
	playerId :: Int,
	playerName :: String,
	--the team of players that this player is in
	playerTeam :: [Player]
} deriving Show
