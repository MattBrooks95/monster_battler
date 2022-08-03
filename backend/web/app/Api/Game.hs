module Api.Game where

import Control.Monad
import Control.Monad.IO.Class

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

game :: ServerPart Response
game = do
	liftIO $ print "in game"
	msum [
			do
				dir "new" $ do
					method GET
					gameId <- liftIO nextRandom
					liftIO $ print gameId
					ok $ toResponse $ encode $ fromList [("gameCode", gameId)]
		] :: ServerPartT IO Response
