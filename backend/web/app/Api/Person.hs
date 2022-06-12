{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Api.Person where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Logger (
		runStderrLoggingT,
		runNoLoggingT
	)

import GHC.Generics

import Data.Aeson
import Data.Aeson.Types
import Data.Maybe

import Database.Persist
import Database.Persist.Class.PersistEntity (
		recordName
	)
import Database.Persist.Postgresql
import Database.Persist.TH

import Data.Database (
		Person(..)
	)

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


person :: ServerPartT IO Response
person = msum [
				do
					method PUT
					request <- askRq
					body <- liftIO $ takeRequestBody request
					let bodyAsJson = getBodyAsJson body
					case bodyAsJson of
						Nothing -> ok $ toResponse ("request body decode failure":: String)
						Just bodyAsJson -> do
							liftIO $ insertPerson bodyAsJson
							ok $ toResponse $ show bodyAsJson,
				do
					method GET
					--people <- getPeople
					liftIO getPeople
					--liftIO $ print people
					ok $ toResponse ("api/person get" :: String)
				--do
				--	method GET
				--	ok $ toResponse "api/person get",
				--do
				--	method DELETE
				--	ok $ toResponse "api/person delete"
			]

getBodyAsJson :: Maybe RqBody -> Maybe PersonJson
getBodyAsJson body =
	case body of
		Just bodySuccess -> do
			let fromJson = decode (unBody bodySuccess) :: Maybe PersonJson
			fromJson
		Nothing -> Nothing

-- TODO can't do this in production
-- TODO you copy and pasted this
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

--runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--flip runSqlPersistMPool pool $ do
insertPerson :: PersonJson -> IO ()
insertPerson person = runNoLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
	personId <- flip runSqlPersistMPool pool $ insert $ Person $ name person
	putStrLn $ show personId

--TODO figure out how to properly use this connection pool, and only
--instantiate one, doing it here and in insertPerson is probably really not good
getPeople :: IO ()
getPeople = runNoLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
	people  <- (flip runSqlPersistMPool pool $ selectList [] []) :: IO [Entity Person]
	print $ "recordName:" ++ (show people)
	--return people
	return ()

