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
		asContentType
	)

main :: IO ()
--main = simpleHTTP nullConf $ ok "Hello, Haskell!!!"
main = simpleHTTP nullConf $ msum
	[
	dir "signup" $ serveFile (asContentType "text/html") "static/index.html",
	dir "account" $ ok $ toResponse "account page",
	dir "welcome" $ ok $ toResponse "welcome page",
	dir "api" $ ok $ toResponse "api endpoint"
	--seeOther "welcome" ""
	]
