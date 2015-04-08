{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Hockey.Database.Types (
    migrate,
    Game(..)
)

where

import Database.Persist.Postgresql hiding (migrate)
import Database.Persist.Sqlite hiding (migrate)
import Database.Persist.TH
import Hockey.Database.Internal
import Hockey.Types (GameState(..))
import Data.Time.Calendar
import Data.Time.LocalTime

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Game
    gameId Int
    awayId String
    homeId String
    date Day
    time TimeOfDay
    tv String
    state GameState
    period Int
    periodTime String
    awayScore Int
    homeScore Int
    awaySog Int
    homeSog Int
    awayStatus String
    homeStatus String
    UniqueGameId gameId
    deriving Show
|]

migrate database = connect database (runMigration migrateAll)
