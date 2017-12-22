
port module PrivateMaine3e8e3e07666443ac33ed21936a19623 exposing (..)

import Platform
import Html exposing (Html)
import ElmHtml.InternalTypes exposing (decodeElmHtml)
import ElmHtml.ToString exposing (nodeToStringWithOptions, defaultFormatOptions)
import Json.Decode as Json
import Native.Jsonify

import View
import Decoder


asJsonView : Html msg -> Json.Value
asJsonView = Native.Jsonify.stringify

options = { defaultFormatOptions | newLines = True, indent = 4 }

decode : Html msg -> String
decode view =
    case Json.decodeValue decodeElmHtml (asJsonView view) of
        Err str -> "ERROR:" ++ str
        Ok str -> nodeToStringWithOptions options str


init : Json.Value -> ((), Cmd msg)
init values =
    case Json.decodeValue Decoder.decodeModel values of
        Err err -> ((), htmlOute3e8e3e07666443ac33ed21936a19623 ("ERROR:" ++ err))
        Ok model ->
            ((), htmlOute3e8e3e07666443ac33ed21936a19623 <| decode <| View.view model)


main = Platform.programWithFlags
    { init = init
    , update = (\_ b -> (b, Cmd.none))
    , subscriptions = (\_ -> Sub.none)
    }

port htmlOute3e8e3e07666443ac33ed21936a19623 : String -> Cmd msg
