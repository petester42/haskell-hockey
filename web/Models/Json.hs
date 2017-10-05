{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Models.Json
  ( Matchup(..)
  , Game(..)
  , Period(..)
  , Event(..)
  , Bracket(..)
  , seedToMatchup
  ) where

import Data.Char as Char
import Data.List as List
import Data.Text
import Hockey.Database
import Hockey.Formatting
       (formattedGame, formattedSeason, formattedYear, intToInteger,
        fromStrength, fromEventType, boolToInt)
import Hockey.Types (Season(..))
import Yesod

-- Matchup
instance ToJSON PlayoffSeed where
  toJSON PlayoffSeed {..} =
    object
      [ "seasonId" .=
        (formattedYear (intToInteger playoffSeedYear) ++
         formattedSeason Playoffs)
      , "conference" .= playoffSeedConference
      , "seed" .= playoffSeedSeries
      , "homeId" .= playoffSeedHomeId
      , "awayId" .= playoffSeedAwayId
      , "round" .= playoffSeedRound
      ]

-- Team
instance ToJSON Game where
  toJSON Game {..} =
    object
      [ "seasonId" .=
        (formattedYear (intToInteger gameYear) ++ formattedSeason gameSeason)
      , "awayId" .= gameAwayId
      , "homeId" .= gameHomeId
      , "awayScore" .= gameAwayScore
      , "homeScore" .= gameHomeScore
      , "gameId" .= show gameGameId
      , "date" .= show gameDate
      , "time" .= show gameTime
      , "tv" .= gameTv
      , "period" .= gamePeriod
      , "periodTime" .= List.map Char.toUpper gamePeriodTime
      , "homeStatus" .= gameHomeStatus
      , "awayStatus" .= gameAwayStatus
      , "homeHighlight" .= gameHomeHighlight
      , "awayHighlight" .= gameAwayHighlight
      , "homeCondense" .= gameHomeCondense
      , "awayCondense" .= gameAwayCondense
      , "active" .= gameActive
      ]

-- Period
instance ToJSON Period where
  toJSON Period {..} =
    object
      [ "teamId" .= periodTeamId
      , "gameId" .= show periodGameId
      , "period" .= periodPeriod
      , "goals" .= periodGoals
      , "shots" .= periodShots
      ]

-- Event
instance ToJSON Event where
  toJSON Event {..} =
    object
      [ "eventId" .= eventEventId
      , "gameId" .= show eventGameId
      , "teamId" .= eventTeamId
      , "period" .= eventPeriod
      , "time" .= eventTime
      , "type" .= fromEventType eventEventType
      , "description" .= eventDescription
      , "videoLink" .= eventVideoLink
      , "formalId" .= eventFormalId
      , "strength" .= fromStrength eventStrength
      ]

data Matchup = Matchup
  { id :: String
  , homeId :: String
  , awayId :: String
  , conference :: String
  , seed :: Int
  , round :: Int
  } deriving (Show)

seedToMatchup :: PlayoffSeed -> Matchup
seedToMatchup seed =
  Matchup
    (formattedYear (intToInteger (playoffSeedYear seed)) ++
     formattedSeason Playoffs ++
     "0" ++ show (playoffSeedRound seed) ++ show (playoffSeedSeries seed))
    (playoffSeedHomeId seed)
    (playoffSeedAwayId seed)
    (playoffSeedConference seed)
    (playoffSeedSeries seed)
    (playoffSeedRound seed)

instance ToJSON Matchup where
  toJSON Matchup {..} =
    object
      [ "id" .= pack id
      , "homeId" .= homeId
      , "awayId" .= awayId
      , "conference" .= conference
      , "seed" .= seed
      , "round" .= round
      ]

data Bracket = Bracket
  { year :: String
  , matchups :: [Matchup]
  } deriving (Show)

instance ToJSON Bracket where
  toJSON Bracket {..} = object ["year" .= pack year, "matchups" .= matchups]
