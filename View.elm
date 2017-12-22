module View exposing (view)

import Data exposing (Model)
import Html exposing (..)


view : Model -> Html msg
view model =
    div [] <|
        List.map (\name -> div [] [ text name ]) model
