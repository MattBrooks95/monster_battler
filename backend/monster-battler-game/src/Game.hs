module Game where
import Game.Player
import Game.PlayerAction (
		PotentialAction(..),
		Action(..),
		Switch(..),
		Forfeit(..),
		Move(..),
	)

--support 2 players vs 2 players
--data BattleMode = FreeForAll | TeamFreeForAll |
data BattleMode = FreeForAll deriving Show

data GameResult = GameResult {
	victors :: [[Player]]
} deriving Show

data Game = Game {
	player_teams :: [[Player]],
	battle_mode :: BattleMode
} deriving Show

getPlayersActions :: Game -> Int -> [PotentialAction]
getPlayersActions game playerId = [PotentialAction playerId (ActionForfeit Forfeit)]
