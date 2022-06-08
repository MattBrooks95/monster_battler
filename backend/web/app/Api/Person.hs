{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveAnyClass #-}

module Api.Person where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Logger
import Database.Persist.Postgresql

import GHC.Generics
import Data.Aeson
import Data.Aeson.Types
import Data.Maybe

import qualified Data.ByteString.Lazy as LB

import Happstack.Server (
		ServerPartT,
		Response,
		dir,
		Method(GET, PUT, DELETE),
		method,
		ok,
		toResponse,
		BodyPolicy,
		defaultBodyPolicy,
		rqBody,
		askRq,
		takeRequestBody,
		unBody,
		RqBody
	)

data PersonJson = PersonJson { name::String } deriving (Show, Generic, ToJSON, FromJSON)

-- TODO can't do this in production
-- TODO you copy and pasted this
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

person :: ServerPartT IO Response
person = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
	flip runSqlPersistMPool pool $ do
		msum [
			do
				method PUT
				request <- askRq
				body <- liftIO $ takeRequestBody request
				let bodyAsJson = getBodyAsJson body
				case bodyAsJson of
					Nothing -> ok $ toResponse "request body decode failure"
					Just bodyAsJson -> ok $ toResponse $ show bodyAsJson,
			do
				method GET
				ok $ toResponse "api/person get",
			do
				method DELETE
				ok $ toResponse "api/person delete"
		]

getBodyAsJson :: Maybe RqBody -> Maybe PersonJson
getBodyAsJson body =
	case body of
		Just bodySuccess -> do
			let fromJson = decode (unBody bodySuccess) :: Maybe PersonJson
			fromJson
		Nothing -> Nothing
