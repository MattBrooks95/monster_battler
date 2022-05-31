module Main where

import Control.Monad

import Lib

import Happstack.Server (
		nullConf,
		simpleHTTP,
		toResponse,
		ok,
		seeOther,
		dir,
		serveFile,
		asContentType,
		serveDirectory,
		Browsing(..),
		Method(..),
		method,
		ServerPartT,
		ToMessage
	)

main :: IO ()
--main = simpleHTTP nullConf $ ok "Hello, Haskell!!!"
main = simpleHTTP nullConf $ msum
	[
	dir "signup" $ serveFile (asContentType "text/html") "static/index.html",
	dir "static" $ serveDirectory DisableBrowsing [] "static",
	dir "api" api
	--do dir "account" $ ok $ toResponse "account page",
	--do dir "welcome" $ ok $ toResponse "welcome page",
	----dir "api" $ ok $ toResponse "api endpoint",
	----do dir "api" $ dir "person" (do method PUT
	----				ok $ toResponse "api/person"),
	--(do dir "api" $ apiRouting),
	--do dir "static" $ serveDirectory DisableBrowsing [] "static"
	----seeOther "welcome" ""
	]

--apiRouting :: (ToMessage a) => ServerPartT IO a
--apiRouting = do
--	dir "person" (do method PUT ok $ toResponse "api/person")

--personHandler :: ServerPartT IO String
--personHandler = return (method PUT (return ok $ toResponse "api/person"))

api = msum
	[
		dir "person" $ ok $ toResponse "api/person"
	]
