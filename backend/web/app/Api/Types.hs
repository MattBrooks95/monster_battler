module Api.Types where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Monad.Logger
import Database.Persist
import Database.Persist.Postgresql

import Data.Database (
		Type(..),
		connStr
	)
import Data.Aeson (
		encode
	)

import Happstack.Server (
		ServerPart,
		Response,
		method,
		Method(GET),
		ok,
		toResponse
	)


import Helpers.Printing (
		printWithBorder,
	)

getTypes :: IO[Entity Type]
getTypes = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
	runReaderT (selectList [] []) dbConnection

types :: ServerPart Response
types = msum [
		do
			method GET
			typeEntities <- liftIO getTypes
			liftIO $ printWithBorder typeEntities
			let types = map entityVal typeEntities
			liftIO $ printWithBorder types
			let jsonTypes = encode types
			liftIO $ printWithBorder jsonTypes
			ok $ toResponse jsonTypes
	]
