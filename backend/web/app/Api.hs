module Api where

import Control.Monad

import Happstack.Server (
		ServerPartT,
		Response,
		dir
	)

import Api.Person

api :: ServerPartT IO Response
api = msum
	[
		dir "person" person
	]
