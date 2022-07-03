module Api where

import Control.Monad

import Happstack.Server (
		ServerPartT,
		Response,
		dir
	)

import Api.Person
import Api.Types

api :: ServerPartT IO Response
api = msum
	[
		dir "person" person,
		dir "types" types
	]
