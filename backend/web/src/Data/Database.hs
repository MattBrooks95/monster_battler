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
{-# LANGUAGE DeriveGeneric #-}
module Data.Database where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Logger (runStderrLoggingT)

import GHC.Generics

import Data.Aeson

import Database.Persist
import Database.Persist.TH
import Database.Persist.Postgresql
import Control.Monad.IO.Class (liftIO)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
	name String
	deriving Show Generic ToJSON FromJSON
Account
	ownerId PersonId
	userName String
	deriving Show
|]

-- TODO can't do this in production
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

-- one-off scripts like this can be run from the repl!!!
migrate :: IO()
migrate = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \ pool -> liftIO $ do
	flip runSqlPersistMPool pool $ do
		runMigration migrateAll

