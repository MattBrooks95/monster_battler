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
import Control.Monad (
		mapM_,
		msum,
	)
import Control.Monad.Reader (
		runReaderT,
	)
import Control.Monad.Logger (
		runStderrLoggingT,
		runNoLoggingT
	)

import GHC.Generics

import Data.Aeson
import Data.Maybe (
		fromJust
	)
import Data.List (
		find,
	)

import qualified Data.Map as Map

import Database.Persist
import Database.Persist.TH
import Database.Persist.Postgresql
import Control.Monad.IO.Class (liftIO)

import Helpers.Printing (
		printWithBorder
	)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
	name String
	deriving Show Generic ToJSON FromJSON
Account
	ownerId PersonId
	userName String
	deriving Show
Type
	name String
	strongAttacks [TypeId]
	resists [TypeId]
	deriving Show Generic ToJSON
|]

-- TODO can't do this in production
connStr = "host=localhost dbname=monster_battler user=monster_battler password=monster_battler port=5432"

-- one-off scripts like this can be run from the repl!!!
migrate :: IO()
migrate = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \ pool -> liftIO $ do
	flip runSqlPersistMPool pool $ do
		runMigrationUnsafe migrateAll

astral = "Astral"
dark = "Dark"
holy = "Holy"
ghost = "Ghost"
esper = "Esper"
beast = "Beast"
bug = "Bug"
-- (X, [Y], [Z]), where type X's attacks are strong against Y and X is weak to attacks from Z
matchups = [
		(astral, ([holy, beast], [beast, holy])),
		(dark,  ([astral, esper], [esper, astral])),
		(holy,  ([dark, ghost], [dark, ghost, holy])),
		(ghost, ([ghost, esper], [beast])),
		(esper, ([ghost], [holy])),
		(beast, ([esper, bug], [bug])),
		(bug, ([esper], []))
	] :: [(String, ([String], [String]))]

--from looking at this function sig you can't tell that it could throw an error
--because you're using fromJust
--maybe for sql scripts it's okay?
typeNameToKey :: String -> [Entity Type] -> Database.Persist.Key Type
typeNameToKey typeName entitiesList = entityKey $ fromJust targetEntity
	where
		targetEntity = find (\entity -> getTypeName entity == typeName) entitiesList :: Maybe(Entity Type)

getTypeName :: Entity Type -> String
getTypeName = typeName . entityVal

makeTypes :: IO()
makeTypes = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
	typeIds <- runReaderT (insertMany types) dbConnection
	print typeIds
	where
	types = [
			Type { typeName = "Astral", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Dark", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Holy", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Ghost", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Esper", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Beast", typeStrongAttacks = [], typeResists = [] },
			Type { typeName = "Bug", typeStrongAttacks = [], typeResists = [] }
		]

--I got them into the database, but I think it's doing updates in a loop
--this is potentially bad for performance and means that I had to change the type of this function from
--IO () to IO [()]
makeTypeMatchups :: IO [()]
makeTypeMatchups = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
	typeEntities <- runReaderT (selectList [] []) dbConnection :: IO[Entity Type]
	printWithBorder typeEntities
	let typeNameToKeyMap = Map.fromList [ (getTypeName entity, typeNameToKey (getTypeName entity) typeEntities) | entity <- typeEntities]
	printWithBorder typeNameToKeyMap
	--let matchupsListAsKeys = [ ((typeNameToKeyMap Map.! (fst matchup)), [], []) | matchup <- matchups] :: [(Database.Persist.Key Type, [], [])]
	let matchupsListAsKeys = [ (typeNameToKeyMap Map.! fst matchup, (map (typeNameToKeyMap Map.!) (fst $ snd matchup), map (typeNameToKeyMap Map.!) (snd $ snd matchup))) | matchup <- matchups] :: [(Database.Persist.Key Type, ([TypeId], [TypeId]))]
	printWithBorder matchupsListAsKeys
	--map (\typeEntity -> update (entityKey typeEntity) [TypeStrongAttacks .= (fst $ snd entityTuple), TypeResists .= (snd $ snd entityTuple)]) typeEntities
	--it's complaining that runReaderT is only good for one action, gotta map it somehow
	--runReaderT (map (\matchup -> update (fst matchup) [TypeStrongAttacks =. (fst $ snd matchup), TypeResists =. (snd $ snd matchup)]) matchupsListAsKeys) dbConnection
	--'list up' the actions that I want to be done [insert the type matchup keys into the entities]
	let updateActions = map (\matchup -> update (fst matchup) [TypeStrongAttacks =. fst (snd matchup), TypeResists =. snd (snd matchup)]) matchupsListAsKeys--runReaderT (map (\matchup -> update (fst matchup) [TypeStrongAttacks =. (fst $ snd matchup), TypeResists =. (snd $ snd matchup)]) matchupsListAsKeys) dbConnection
	--then, use mapM to 'run' those actions through the run reader transformer 
	mapM (\action -> runReaderT action dbConnection) updateActions

