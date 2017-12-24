module Docs.Version exposing
  ( Version
  , Dictionary
  , MinorPatch
  , decoder
  , filterInteresting
  , realMax
  , toDict
  , fromStringList
  , vsnToString
  )

import Dict
import Json.Decode as Decode exposing (Decoder)
import String


type alias Version = (Int, Int, Int)



-- JSON DECODER


decoder : Decoder Version
decoder =
  Decode.string
    |> Decode.andThen (fromString >> resultToDecoder)


resultToDecoder : Result String a -> Decoder a
resultToDecoder result =
  case result of
    Ok a ->
      Decode.succeed a

    Err err ->
      Decode.fail err


fromString : String -> Result String Version
fromString str =
  case all (List.map String.toInt (String.split "." str)) of
    Ok [major, minor, patch] ->
        Ok (major, minor, patch)

    _ ->
        Err (str ++ " is not a valid Elm version")


all : List (Result x a) -> Result x (List a)
all list =
  case list of
    [] ->
        Ok []

    x :: xs ->
        Result.map2 (::) x (all xs)


fromStringList : List String -> Result String (List Version)
fromStringList versions =
  all (List.map fromString versions)



-- MAXIMUM


realMax : String -> List String -> Maybe String
realMax rawVsn allRawVsns =
  case Result.map2 (,) (fromString rawVsn) (fromStringList allRawVsns) of
    Ok (version, allVersions) ->
      let
        maxVersion =
          List.foldl max version allVersions
      in
        if version == maxVersion then
            Nothing

        else
            Just (vsnToString maxVersion)

    _ ->
        Nothing



-- TO STRING


vsnToString : Version -> String
vsnToString (major, minor, patch) =
  toString major ++ "." ++ toString minor ++ "." ++ toString patch



-- INTERESTING VERSIONS


filterInteresting : List Version -> List Version
filterInteresting versions =
  List.map (uncurry toLatest) (Dict.toList (toDict versions))


toLatest : Int -> MinorPatch -> Version
toLatest major {latest} =
  let
    (minor, patch) =
      latest
  in
    (major, minor, patch)



-- TO DICTIONARY


type alias Dictionary =
  Dict.Dict Int MinorPatch



type alias MinorPatch =
  { latest : (Int, Int)
  , others : List (Int, Int)
  }


toDict : List Version -> Dictionary
toDict versions =
  List.foldl toDictHelp Dict.empty versions


toDictHelp : Version -> Dictionary -> Dictionary
toDictHelp (major, minor, patch) dict =
  let
    current =
      (minor, patch)

    update maybeMinorPatch =
      case maybeMinorPatch of
        Nothing ->
          Just (MinorPatch current [])

        Just {latest, others} ->
          Just (MinorPatch (max latest current) (insert (min latest current) others))
  in
    Dict.update major update dict


insert : comparable -> List comparable -> List comparable
insert y list =
  case list of
    [] ->
      [y]

    x :: xs ->
      if y > x then
        x :: insert y xs

      else
        y :: list
