module Lib where
import Game

-- TODO I don't think I need this. I should just test from the web client or in ghci
testGame :: IO ()
testGame = do
	print "testGame"
	let dummyGame = Game { player_teams = [], battle_mode = FreeForAll }
	print dummyGame
