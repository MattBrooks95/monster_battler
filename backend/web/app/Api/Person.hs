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
import Data.Map (
		Map
	)

import qualified Data.Map as Map

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

import Data.Person (
		getPeople,
		insertPerson,
	)

import qualified Data.ByteString.Lazy as LB
import qualified Data.ByteString.Lazy.UTF8 as UC(
		fromString,
	)

import Happstack.Server (
		ServerPartT,
		ServerPart,
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

import Helpers.Printing (
		printWithBorder
	)

import Control.Monad.Reader

person :: ServerPart Response
person = msum [
				do
					method PUT
					request <- askRq
					body <- takeRequestBody request
					case body of
						Just body -> liftIO $ print "just body"
						Nothing -> liftIO $ print "take body failure"
					let personObjectFromRequest = getPersonFromBody body
					liftIO $ print (show personObjectFromRequest)
					case personObjectFromRequest of
						Nothing -> badRequest $ toResponse ("failure to decode request body or JSON" :: String)
						Just person -> do
							personId <- liftIO $ insertPerson person
							ok $ toResponse ("added person" ++ (show personId))
				, do
					method GET
					--get people entities from database
					peopleEntities <- liftIO getPeople
					liftIO $ printWithBorder peopleEntities
					-- turn the persist entities into actual objects
					let people = map entityVal peopleEntities
					liftIO $ printWithBorder people

					-- turn the objects into json TODO wrap in in a Data.Map { people: values }, right now it's just an array
					let jsonPeople = encode people
					liftIO $ printWithBorder jsonPeople
					-- happstack json response
					ok $ toResponse jsonPeople

				--do
				--	method DELETE
				--	ok $ toResponse "api/person delete"
			] :: ServerPart Response

getBodyFromRequest :: RqBody -> LB.ByteString
getBodyFromRequest = unBody

getPersonFromBody :: Maybe RqBody -> Maybe Person
getPersonFromBody body = case body of
	Just body -> decode $ unBody body
	Nothing -> Nothing
