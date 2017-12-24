module Docs.Package exposing
  ( Package
  , Module
  , decodePackage
  , decodeModule
  )

import Dict
import Json.Decode as Json

import Docs.Name as Name
import Docs.Entry as Entry



-- TYPES


type alias Package =
    Dict.Dict String Module


type alias Module =
    { name : String
    , comment : String
    , entries : Dict.Dict String (Entry.Model String)
    }



-- DECODERS


decodePackage : Json.Decoder Package
decodePackage =
  Json.map (dictBy .name) (Json.list decodeModule)


decodeModule : Json.Decoder Module
decodeModule =
  let
    make name comment values unions aliases =
      Module name comment (dictBy .name (values ++ unions ++ aliases))
  in
    Json.map5 make
      (Json.field "name" Json.string)
      (Json.field "comment" Json.string)
      (Json.field "aliases" (Json.list (entry alias)))
      (Json.field "types" (Json.list (entry union)))
      (Json.field "values" (Json.list (entry value)))


dictBy : (a -> comparable) -> List a -> Dict.Dict comparable a
dictBy f list =
  Dict.fromList (List.map (\x -> (f x, x)) list)



-- ENTRY


entry : Json.Decoder (Entry.Info String) -> Json.Decoder (Entry.Model String)
entry decodeInfo =
  Json.map3 Entry.Model
    (Json.field "name" Json.string)
    decodeInfo
    (Json.field "comment" Json.string)



-- VALUE INFO


value : Json.Decoder (Entry.Info String)
value =
  Json.map2 Entry.Value
    (Json.field "type" tipe)
    (Json.maybe fixity)


fixity : Json.Decoder Entry.Fixity
fixity =
  Json.map2 Entry.Fixity
    (Json.field "precedence" Json.int)
    (Json.field "associativity" Json.string)



-- UNION INFO


union : Json.Decoder (Entry.Info String)
union =
  Json.map2
    (\vars tags -> Entry.Union { vars = vars, tags = tags })
    (Json.field "args" (Json.list Json.string))
    (Json.field "cases" (Json.list tag))


tag : Json.Decoder (Entry.Tag String)
tag =
  Json.map2
    Entry.Tag
    (Json.index 0 Json.string)
    (Json.index 1 (Json.list tipe))



-- ALIAS INFO


alias : Json.Decoder (Entry.Info String)
alias =
  Json.map2
    (\vars tipe -> Entry.Alias { vars = vars, tipe = tipe })
    (Json.field "args" (Json.list Json.string))
    (Json.field "type" tipe)



-- TYPES


tipe : Json.Decoder String
tipe =
  Json.string


