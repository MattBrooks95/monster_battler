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

import Data.Person (
		getPeople,
		insertPerson,
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

person :: ServerPartT IO Response
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
					--ok $ toResponse ("TODO" :: String)
					--case personObjectFromRequest of 
					--	Just person -> do
					--		personId <- insertPerson (person :: Person)
					--		ok $ toResponse $ "added person" ++ (show personId)
					--	Nothing -> badRequest $ toResponse ("failure to decode request body or JSON" :: String)--,
				--do
				--	method GET
				--	--people <- getPeople
				--	liftIO getPeople
				--	--liftIO $ print people
				--	ok $ toResponse ("api/person get" :: String)
				--do
				--	method GET
				--	ok $ toResponse "api/person get",
				--do
				--	method DELETE
				--	ok $ toResponse "api/person delete"
			] :: ServerPartT IO Response

getBodyFromRequest :: RqBody -> LB.ByteString
getBodyFromRequest requestBody = unBody requestBody

--getBodyAsJson :: Maybe RqBody -> Maybe PersonJson
--getBodyAsJson body =
--	case body of
--		Just bodySuccess -> do
--			let fromJson = decode (unBody bodySuccess) :: Maybe PersonJson
--			fromJson
--		Nothing -> Nothing

getPersonFromBody :: Maybe RqBody -> Maybe Person
getPersonFromBody body = case body of
	Just body -> (decode $ unBody body)
	Nothing -> Nothing
