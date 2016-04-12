{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Hockey.Parsing (
    decodeResponse
) where

import Hockey.Formatting
import Data.Aeson
import Control.Applicative as Applicative
import Hockey.Types

decodeResponse :: (FromJSON a) => IO String -> IO (Maybe a)
decodeResponse response = do
    rsp <- response
    return $ decode (stringToLazyByteString rsp)

-- Season
instance FromJSON Season

-- GameState
instance FromJSON GameState

-- Game
instance FromJSON Game where
    parseJSON (Object v) = parseGame v
    parseJSON _          = Applicative.empty

parseGame v = Game <$>
    v .: "id" <*>
    fmap unpackToLower (v .: "ata") <*>
    fmap unpackToLower (v .: "hta") <*>
    fmap splitAndJoin (v .: "canationalbroadcasts") <*>
    fmap splitAndJoin (v .: "usnationalbroadcasts") <*>
    fmap toGameState (v .:"gs") <*>
    fmap valueToInteger (v .: "ats") <*>
    fmap valueToInteger (v .: "hts") <*>
    fmap valueToInteger (v .:? "atsog") <*>
    fmap valueToInteger (v .:? "htsog") <*>
    fmap unpackParseTime (v .: "bs") <*>
    fmap removeGameTimeAndPeriod (v .: "bs") <*>
    fmap periodFromPeriodString (v .: "bs")

-- Results
instance FromJSON Results where
    parseJSON (Object v) = parseResults v
    parseJSON _          = Applicative.empty

parseResults v = Results <$>
    v .: "games" <*>
    fmap unpackParseDate (v .: "currentDate") <*>
    fmap unpackParseDate (v .: "nextDate") <*>
    fmap unpackParseDate (v .: "prevDate")

-- GameDate
instance FromJSON GameDate where
    parseJSON (Object v) = parseGameDate v
    parseJSON _          = Applicative.empty

parseGameDate v = GameDate <$>
    fmap unpackParseDate (v .: "gameDate") <*>
    fmap seasonFromGameId (v .: "gamePk") <*>
    (v .: "gamePk")

-- DatesList

instance FromJSON DatesList where
    parseJSON (Object v) = DatesList <$> v .: "dates"
    parseJSON _          = Applicative.empty

-- GameDates

instance FromJSON GameDates where
    parseJSON (Object v) = GameDates <$> v .: "games"
    parseJSON _          = Applicative.empty

-- EventType
instance FromJSON EventType

-- Strength
instance FromJSON Strength

-- Event
instance FromJSON Event where
    parseJSON (Object v) = parseEvent v
    parseJSON _          = Applicative.empty

parseEvent v = Event <$>
    v .: "eventid" <*>
    v .: "teamid" <*>
    v .: "period" <*>
    v .: "time" <*>
    v .: "desc" <*>
    v .: "formalEventId" <*>
    fmap toStrength (v .: "strength") <*>
    v .: "type"

-- EventPlays
instance FromJSON EventPlays where
    parseJSON (Object v) = parseEventPlays v
    parseJSON _          = Applicative.empty

parseEventPlays v = EventPlays <$>
        v .: "play"

-- EventGame
instance FromJSON EventGame where
    parseJSON (Object v) = parseEventGame v
    parseJSON _          = Applicative.empty

parseEventGame v = EventGame <$>
    v .: "awayteamid" <*>
    v .: "hometeamid" <*>
    v .: "awayteamnick" <*>
    v .: "hometeamnick" <*>
    v .: "plays"

-- EventData
instance FromJSON EventData where
    parseJSON (Object v) = parseEventData v
    parseJSON _          = Applicative.empty

parseEventData v = EventData <$>
    v .: "game"

-- GameEvents
instance FromJSON GameEvents where
    parseJSON (Object v) = parseGameEvents v
    parseJSON _          = Applicative.empty

parseGameEvents v = GameEvents <$>
    v .: "data"

-- PeriodData
instance FromJSON PeriodData where
    parseJSON (Object v) = parsePeriodData v
    parseJSON _          = Applicative.empty

parsePeriodData v = PeriodData <$>
        v .: "g" <*>
        v .: "s"

instance FromJSON ScoreboardData where
    parseJSON (Object v) = parseScoreboardData v
    parseJSON _          = Applicative.empty

parseScoreboardData v = ScoreboardData <$>
        fmap unpackToLower (v .: "ab") <*>
        v .: "pa"

instance FromJSON Scoreboard where
    parseJSON (Object v) = parseScoreboard v
    parseJSON _          = Applicative.empty

parseScoreboard v = Scoreboard <$>
    v .: "h" <*>
    v .: "a"
