module Api where

import Control.Monad
import Control.Monad.IO.Class

import Happstack.Server (
		ServerPartT,
		Response,
		dir,
		ok,
		toResponse
	)

import Api.Person
import Api.Types
import Api.Game

api :: ServerPartT IO Response
api = msum
	[
		dir "person" person,
		dir "types" types,
		dir "game" $ do
			liftIO $ print "game api"
			game
	]
