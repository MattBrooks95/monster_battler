module Main where

import Control.Monad

import Happstack.Server (
		nullConf,
		simpleHTTP,
		toResponse,
		ok,
		seeOther,
		dir,
	)

main :: IO ()
--main = simpleHTTP nullConf $ ok "Hello, Haskell!!!"
main = simpleHTTP nullConf $ msum
	[
	dir "signup" $ ok "sign up page",
	dir "welcome" $ ok "welcome page",
	seeOther "welcome" ""
	]
