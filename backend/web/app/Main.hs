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
		ToMessage,
		Response
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

api :: ServerPartT IO Response
api = msum
	[
		dir "person" person
	]

person :: ServerPartT IO Response
-- this works
-- person = ok $ toResponse "api/person"
--so does this
--person = msum
--	[
--		ok $ toResponse "api/person"
--	]
person = msum
	[
		--so, method PUT does nothing besides control which code branch is ran, based on the request
		--that is why the happstack tutorial was using do notation
		--but for some reason, do notation did not work when I tried it
		--if it was because of whitespace or indentation, that's just silly
		--this is the same as the happstack guide, doesn't work because "Couldn't match type ‘()’ with ‘Response -> ServerPartT IO Response’"
		--the reason this does not work is because the 'm' in method (the first line of the do block) and the '(' or 'r' on the second line do not line-up
		--they have to be on exactly the same column
		--do method PUT
		--	(return (ok $ toResponse "api/person put"))
		--like this
		do
			method PUT
			ok $ toResponse "api/person put",
		do
			method GET
			ok $ toResponse "api/person get",
		do
			method DELETE
			ok $ toResponse "api/person delete"


		--this works and I think this syntax is nicer, but why does the do block not work?
		--the thing1 >> thing2 operator does thing1, ignores any return value it might have had, and then returns the result of thing2
		--method PUT >> (ok $ toResponse "api/person put")
	]
