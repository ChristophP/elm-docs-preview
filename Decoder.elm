module Decoder exposing (decodeModel)

import Data exposing (Model)
import Json.Decode exposing (Decoder, field, list, string)


decodeModel : Decoder Model
decodeModel =
    list <| field "name" string
