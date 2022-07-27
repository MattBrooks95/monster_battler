module Game where
import Game.Player

--support 2 players vs 2 players
--data BattleMode = FreeForAll | TeamFreeForAll |
data BattleMode = FreeForAll deriving Show

data GameResult = GameResult {
	victors :: [[Player]]
}

data Game = Game {
	player_teams :: [[Player]],
	battle_mode :: BattleMode
} deriving Show

runGame :: Game -> GameResult
runGame game = GameResult { victors = player_teams game } --you're all winners
