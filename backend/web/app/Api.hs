{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveAnyClass #-}
module Api where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Logger

import Happstack.Server (
		ServerPartT,
		Response,
		dir
	)

import Database.Persist.Postgresql

import Api.Person

-- TODO can't do this in production
-- TODO you copy and pasted this
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

api :: ServerPartT IO Response
api = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
	flip runSqlPersistMPool pool $
		msum
		[
			dir "person" person
		]
