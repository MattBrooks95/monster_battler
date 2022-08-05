module ServerState where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Network.WebSockets as WS

data GamePlayerConnection = GamePlayerConnection {
	playerName :: Text,
	connection :: WS.Connection
}

data Game = Game { playerOneRoll::Int, playerTwoRoll::Int }

data GameInstance = GameInstance {
		gameCode :: Text,
		game :: Game,
		playerOneConnection :: GamePlayerConnection,
		playerTwoConnection :: GamePlayerConnection
	}
data ServerState = ServerState [GameInstance]
