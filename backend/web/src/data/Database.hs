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

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Logger (runStderrLoggingT)

import Database.Persist
import Database.Persist.TH
import Database.Persist.Postgresql
import Control.Monad.IO.Class (liftIO)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
	name String
	age Int
	deriving Show
|]

-- TODO can't do this in production
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

-- one-off scripts like this can be run from the repl!!!
main:: IO()
main = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \ pool -> liftIO $ do
	flip runSqlPersistMPool pool $ do
		runMigration migrateAll

