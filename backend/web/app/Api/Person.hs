{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveAnyClass #-}

module Api.Person where

import Control.Monad
import Control.Monad.IO.Class

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

-- this works
-- person = ok $ toResponse "api/person"
--so does this
--person = msum
--	[
--		ok $ toResponse "api/person"
--	]
person :: ServerPartT IO Response
person = msum
	[
		do
			method PUT
			request <- askRq
			body <- liftIO $ takeRequestBody request
			getBodyAsJson body
		--do
		--	method GET
		--	ok $ toResponse "api/person get",
		--do
		--	method DELETE
		--	ok $ toResponse "api/person delete"
	]

getBodyAsJson :: Maybe RqBody -> ServerPartT IO Response
getBodyAsJson body =
	case body of
		Just bodySuccess -> do
			-- declaring PersonJson here was necessary to resolve a type ambiguity that
			-- the compiler complained about
			let fromJson = decode (unBody bodySuccess) :: Maybe PersonJson
			let response = case fromJson of
				Just jsonSuccess -> ok $ toResponse $ show jsonSuccess
				Nothing -> ok $ toResponse "died because of json decode failure"
			response
		Nothing -> ok $ toResponse "died because takeRequestBody failure"
