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
		Person(..),
		connStr
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
		RqBody,
		badRequest
	)

import Control.Monad.Reader

--data PersonJson = PersonJson { name::String } deriving (Show, Generic, ToJSON, FromJSON)


person :: ServerPartT IO Response
person = msum [
				do
					method PUT
					request <- askRq
					body <- liftIO $ takeRequestBody request
					case body of
						Just body -> do
							bodyJson <- decode $ unBody body
							case bodyJson of
								Just bodyJson -> do
									personId <- liftM insertPerson bodyJson
									ok $ toResponse $ "added person" ++ (show personId)
								Nothing -> do
									liftM print "couldn't decode the request's json"
									badRequest $ toResponse "couldn't decode the request's json"
						Nothing -> do
							liftM print "Couldn't get body from request"
							badRequest $ toResponse "Couldn't get body from request",
					--let bodyAsJson = getBodyAsJson body
					--case bodyAsJson of
					--	Nothing -> ok $ toResponse ("request body decode failure":: String)
					--	Just bodyAsJson -> do
					--		liftIO $ insertPerson (decode bodyAsJson)
					--		ok $ toResponse $ show bodyAsJson,
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

getBodyFromRequest :: RqBody -> LB.ByteString
getBodyFromRequest requestBody = unBody requestBody

--getBodyAsJson :: Maybe RqBody -> Maybe PersonJson
--getBodyAsJson body =
--	case body of
--		Just bodySuccess -> do
--			let fromJson = decode (unBody bodySuccess) :: Maybe PersonJson
--			fromJson
--		Nothing -> Nothing

--runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--flip runSqlPersistMPool pool $ do
insertPerson :: Person -> IO (Database.Persist.Postgresql.Key Person)
--insertPerson person = runNoLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--	personId <- flip runSqlPersistMPool pool $ insert $ Person $ name person
--	putStrLn $ show personId
insertPerson person = runNoLoggingT $ withPostgresqlConn connStr $ \backend -> runReaderT (insert $ person) backend

--TODO figure out how to properly use this connection pool, and only
--instantiate one, doing it here and in insertPerson is probably really not good
--in ghci, I was playing around with how to get the actual Person values out of these
--io actions:
--ghci> fmap (\x -> fmap entityVal x) myPeople
--[Person {personName = "success"},Person {personName = "person 2"}]
--there's gotta be abetter way than calling fmap twice
--I learned that I can do this:
--let myPeople = getPeople
--ghci> fmap (map entityVal) myPeople
--[Person {personName = "first person in database!!!"},Person {personName = "name 2"}]
--`fmap entityVal person` is no good because it is prepared to handle the IO monad, but it is not
--prepared to also handle the List monad. `map entityVal` uses partial function application
--to create a function that has the type map entityVal :: [Entity b] -> [b]
--which is a pure function that turns People Entities (from the Database library), into People objects
--so, by passing that into fmap, we get this:
--ghci> :t fmap (map entityVal)
--fmap (map entityVal) :: Functor f => f [Entity b] -> f [b]
--so, this code can turn Entities in the IO monad into People in the IO monad
--I should be able to continue this train of thought to be able to go from Database Object -> JSON
--getPeople :: IO [Entity Person]
--getPeople = runNoLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--	people  <- (flip runSqlPersistMPool pool $ selectList [] []) :: IO [Entity Person]
--	--print $ "recordName:" ++ (show people)
--	--return people
--	return people

getPeople :: IO [Entity Person]
getPeople = runNoLoggingT $ withPostgresqlConn connStr $ \backend -> runReaderT (selectList [] []) backend

