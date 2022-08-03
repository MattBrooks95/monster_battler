module ServerState where

import qualified Network.WebSockets as WS

data GamePlayerConnection = GamePlayerConnection {
	playerName :: Text,
	connection :: WS.Connection
}

data Game = Game { playerOneRoll::Int, playerTwoRoll::Int }

type GameInstance = (Text, Game, GamePlayerConnection, GamePlayerConnection)
data ServerState = ServerState [GameInstance]
