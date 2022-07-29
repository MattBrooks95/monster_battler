module GameRunner.Terminal where
import Game (Game (..), GameResult (..))
import Game.PlayerAction (PotentialAction (..), Action (..), Forfeit (Forfeit))

run :: IO ()
run = do
	print "enter player 1's name:"
	player1Name <- getLine
	print "enter player 2's name:"
	player2Name <- getLine
	
	print "player 1 monster selection:"

	GameResult { victors = player_teams game } --you're all winners
