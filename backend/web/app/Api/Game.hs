module Api.Game where

import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent (
		modifyMVar
	)

import Data.UUID (
		toString,
	)
import Data.UUID.V4 (
		nextRandom
	)

import Happstack.Server (
		ServerPartT,
		ServerPart,
		Response,
		dir,
		Method(GET, PUT, DELETE),
		method,
		ok,
		toResponse
	)
import Data.Aeson
import Data.Map (
		Map,
		fromList
	)
import qualified Data.Map as Map

import Control.Concurrent (
		modifyMVar_,
	)

import ServerState (
		ServerState(..)
	)

game :: ServerState -> ServerPart Response
game state = do
	liftIO $ print "in game"
	msum [
			do
				dir "new" $ do
					method GET
					gameId <- liftIO nextRandom
					liftIO $ print gameId
					ok $ toResponse $ encode $ fromList [("gameCode", gameId)]
				dir "connect" $ do
					method GET
					request <- askRq
					body <- takeRequestBody request
					case body of
						Just body -> do
							bodyJson <- (decode $ unbody body)-- :: Map { gameCode :: String }
							case bodyJson of
							-- TODO create a websocket connection when the client sends
							-- a connection request with the uuid we gave them
							-- will need a way to figure out who is player one and who is player two
							-- probably, when the game code is created we should just add an entry into
							-- the server state that specifies the client that requested the code
							-- as being player one
								Just connectBody -> do
									let gameCodeFromRequest = gameCode connectBody
									let gameToConnectTo = find (\x -> gameCodeFromRequest == gameCode x) state
									case gameToConnectTo of
										Just gameInstance -> modifyMVar_ \s -> do
											let s' = (GamePlayerConnection { playerName = "hoge", } : state
										Nothing ->
								Nothing -> ok $ toResponse "game/connect body deserialization failure"
						Nothing -> ok $ toResponse "bad game/connect body"
		] :: ServerPartT IO Response
