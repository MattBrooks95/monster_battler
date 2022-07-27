module Lib where
import Game

testGame :: IO ()
testGame = do
	print "testGame"
	let dummyGame = Game { player_teams = [], battle_mode = FreeForAll }
	print dummyGame
	print $ runGame dummyGame
