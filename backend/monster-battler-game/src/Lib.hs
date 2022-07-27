module MyLib where
import Game

testGame :: Game -> IO GameResult
testGame game = do
	print "testGame"
	print game
	return $ runGame game
