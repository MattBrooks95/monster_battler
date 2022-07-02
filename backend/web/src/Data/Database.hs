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
	deriving Show
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
		targetEntity = find (\entity -> (getTypeName entity) == typeName) entitiesList :: Maybe(Entity Type)

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

getTypes :: IO[Entity Type]
getTypes = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
	runReaderT (selectList [] []) dbConnection

makeTypeMatchups :: IO ()
makeTypeMatchups = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
	typeEntities <- runReaderT (selectList [] []) dbConnection :: IO[Entity Type]
	printWithBorder typeEntities
	let typeNameToKeyMap = Map.fromList [ (getTypeName entity, typeNameToKey (getTypeName entity) typeEntities) | entity <- typeEntities]
	printWithBorder typeNameToKeyMap
	--let matchupsListAsKeys = [ ((typeNameToKeyMap Map.! (fst matchup)), [], []) | matchup <- matchups] :: [(Database.Persist.Key Type, [], [])]
	let matchupsListAsKeys = [ (typeNameToKeyMap Map.! (fst matchup), (map (typeNameToKeyMap Map.!) (fst $ snd matchup), map (typeNameToKeyMap Map.!) (snd $ snd matchup))) | matchup <- matchups] :: [(Database.Persist.Key Type, ([TypeId], [TypeId]))]
	printWithBorder matchupsListAsKeys
	--map (\typeEntity -> update (entityKey typeEntity) [TypeStrongAttacks .= (fst $ snd entityTuple), TypeResists .= (snd $ snd entityTuple)]) typeEntities
	--it's complaining that runReaderT is only good for one action, gotta map it somehow
	--runReaderT (map (\matchup -> update (fst matchup) [TypeStrongAttacks =. (fst $ snd matchup), TypeResists =. (snd $ snd matchup)]) matchupsListAsKeys) dbConnection
	map (\matchup -> runReaderT (update (fst matchup) [TypeStrongAttacks =. (fst $ snd matchup), TypeResists =. (snd $ snd matchup)]) dbConnection) matchupsListAsKeys--runReaderT (map (\matchup -> update (fst matchup) [TypeStrongAttacks =. (fst $ snd matchup), TypeResists =. (snd $ snd matchup)]) matchupsListAsKeys) dbConnection

	--mapM_ (\entityTuple -> runReaderT $ (update (fst entityTuple) [TypeStrongAttacks .= (fst $ snd entityTuple), TypeResists .= (snd $ snd entityTuple)]) dbConnection) matchupsListAsKeys
	--map (\entityTuple -> (update (fst entityTuple) [TypeStrongAttacks .= (fst $ snd entityTuple), TypeResists .= (snd $ snd entityTuple)])) matchupsListAsKeys
	--update $ (fst $ head matchupsListAsKeys) [TypeStrongAttacks .= (fst $ snd (head matchupsListAsKeys)), TypeResists .= (snd $ snd ( head matchupsListAsKeys))]

	--mapM_ (\entity -> update (entityKey entity) [TypeStrongAttacks .= , TypeResists .=]) typeEntities
	--let entitiesWithMatchups = [ getMatchups $ typeNameToKey x | x <- typeEntities]

--makeTypeMatchups :: IO ()
--makeTypeMatchups = runNoLoggingT $ withPostgresqlConn connStr $ \dbConnection -> liftIO $ do
--	types <- runReaderT (selectList [] []) dbConnection :: IO[Entity Type]
--	print types
--	let updatedTypes = map getMatchup types
--	print updatedTypes
--
--getMatchup :: Entity Type -> [Entity Type] -> Maybe ([Database.Persist.Key Type], [Database.Persist.Key Type])
--getMatchup typeEntity typeEntitiesList =
--	(find (\x -> (typeName $ entityVal x) ) typeEntitiesList, find
--	where
--		matchupLookupResult = fromJust $ lookup (typeName $ entityVal typeEntity) matchups
--		thisTypeName = typeName $ entityVal typeEntity


-- this infinite looped as it was evaluating the types that were referencing eachother, I think
-- or perhaps it was the ghost <---> ghost reciprocal weakness
-- \backend -> runReaderT (insertMany_ [astral, dark, holy, ghost, esper, beast, bug]) backend
--where
--	astral = Type { typeName = "Astral", typeStrongAttacks = [holy, beast], typeResists = [beast, holy] }
--	dark = Type { typeName = "Dark", typeStrongAttacks = [astral, esper], typeResists = [esper, astral] }
--	holy = Type { typeName = "Holy", typeStrongAttacks = [dark, ghost], typeResists = [dark, ghost, holy] }
--	ghost = Type { typeName = "Ghost", typeStrongAttacks = [ghost, esper], typeResists = [beast] }
--	esper = Type { typeName = "Esper", typeStrongAttacks = [ghost], typeResists = [holy] }
--	beast = Type { typeName = "Beast", typeStrongAttacks = [esper, bug], typeResists = [bug] }
--	bug = Type { typeName = "Bug", typeStrongAttacks = [esper], typeResists = [] }

