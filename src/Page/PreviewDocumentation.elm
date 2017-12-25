port module Page.PreviewDocumentation exposing (..)

import Component.Header as Header
import Component.PackagePreview as Preview
import Docs.Package as Docs
import Html exposing (..)
import Json.Decode as Json


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { header : Header.Model
    , preview : Preview.Model
    }



-- INIT


init : Json.Value -> ( Model, Cmd Msg )
init value =
    let
        docs =
            case Json.decodeValue Docs.decodePackage value of
                Err err ->
                    Preview.BadFile (Just <| "Could not parse file contents as Elm docs. " ++ err)

                Ok dict ->
                    Preview.GoodFile dict (Preview.docsForModule "" dict)

        ( header, headerCmd ) =
            Header.init

        ( preview, previewCmd ) =
            Preview.init docs
    in
    ( Model header preview
    , Cmd.batch
        [ headerCmd
        , Cmd.map UpdatePreview previewCmd
        ]
    )



-- UPDATE


type Msg
    = UpdatePreview Preview.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdatePreview subMsg ->
            let
                ( preview, previewCmd ) =
                    Preview.update subMsg model.preview
            in
            ( { model | preview = preview }, Cmd.map UpdatePreview <| previewCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



--toDocs : String -> Preview.Msg
--toDocs body =
--case Json.decodeString Docs.decodePackage body of
--Err _ ->
--Preview.Fail (Just "Could not parse file contents as Elm docs.")
--Ok dict ->
--Preview.LoadDocs dict
-- VIEW


view : Model -> Html Msg
view model =
    Html.map UpdatePreview
        (Header.view model.header (Preview.view model.preview))
