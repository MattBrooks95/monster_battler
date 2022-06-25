module Data.Person where

import Control.Monad.Logger (
		runNoLoggingT
	)

import Control.Monad.Reader (
		runReaderT,
	)

import Database.Persist.Class.PersistEntity (
		recordName,
		Entity
	)

import Database.Persist (
		selectList,
		insert
	)

import Database.Persist.Postgresql (
		Key,
		withPostgresqlConn,
	)

import Data.Database (
		Person(..),
		connStr
	)

getPeople :: IO [Entity Person]
getPeople = runNoLoggingT $ withPostgresqlConn connStr $ \backend -> runReaderT (selectList [] []) backend

--TODO this code can be moved to a database module
--runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--flip runSqlPersistMPool pool $ do
insertPerson :: Person -> IO (Database.Persist.Postgresql.Key Person)
--insertPerson person = runNoLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
--	personId <- flip runSqlPersistMPool pool $ insert $ Person $ name person
--	putStrLn $ show personId
insertPerson person = runNoLoggingT $ withPostgresqlConn connStr $ \backend -> runReaderT (insert $ person) backend
