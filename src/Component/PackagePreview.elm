module Component.PackagePreview exposing (..)

import Component.PackageDocs as PDocs
import Dict
import Docs.Package as Docs
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils.Markdown as Markdown
import Utils.Path as Path


-- MODEL


type Model
    = BadFile (Maybe String)
    | GoodFile (Dict.Dict String Docs.Module) PDocs.Model


init : Model -> ( Model, Cmd Msg )
init model =
    flip (,) Cmd.none <|
        case model of
            BadFile maybe ->
                BadFile maybe

            GoodFile docs moduleName ->
                case List.head (Dict.keys docs) of
                    Nothing ->
                        BadFile (Just "The JSON you uploaded does not have any modules in it!")

                    Just moduleName ->
                        GoodFile docs (docsForModule moduleName docs)



-- UPDATE


type Msg
    = NoOp
    | SwitchTo String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    flip (,) Cmd.none <|
        case msg of
            NoOp ->
                model

            SwitchTo moduleName ->
                case model of
                    GoodFile docs _ ->
                        GoodFile docs (docsForModule moduleName docs)

                    _ ->
                        model



-- VIEW


(=>) =
    (,)


view : Model -> List (Html Msg)
view model =
    case model of
        BadFile maybeMsg ->
            let
                errorMsg =
                    case maybeMsg of
                        Just msg ->
                            "Problem uploading that file: " ++ msg

                        Nothing ->
                            "Problem uploading that file, try it a different way."
            in
            [ instructions long
            , p [ style [ "color" => "red" ] ] [ text errorMsg ]
            ]

        GoodFile docs info ->
            [ instructions short
            , div
                [ style
                    [ "border-top" => "1px solid #eeeeee"
                    , "margin-top" => "1em"
                    ]
                ]
                [ PDocs.view info
                , viewSidebar (Dict.keys docs)
                ]
            ]


viewSidebar : List String -> Html Msg
viewSidebar modulesNames =
    div [ class "pkg-nav" ]
        [ ul
            [ class "pkg-nav-value" ]
            (moduleLinks modulesNames)
        ]


moduleLinks : List String -> List (Html Msg)
moduleLinks modulesNames =
    let
        moduleItem moduleName =
            li [] [ moduleLink moduleName ]
    in
    List.map moduleItem modulesNames


moduleLink : String -> Html Msg
moduleLink moduleName =
    a
        [ onClick (SwitchTo moduleName)
        , class "pkg-nav-module"
        , href ("#" ++ Path.hyphenate moduleName)
        ]
        [ text moduleName ]



-- DOCS FUNCTIONS


docsForModule : String -> Dict.Dict String Docs.Module -> PDocs.Model
docsForModule moduleName docs =
    case Dict.get moduleName docs of
        Just moduleDocs ->
            let
                chunks =
                    PDocs.toChunks moduleDocs
                        |> List.map (PDocs.chunkMap PDocs.stringToType)
            in
            PDocs.ParsedDocs (PDocs.Info moduleName (PDocs.toNameDict docs) chunks)

        Nothing ->
            PDocs.Failed <| "OMG could not find module " ++ moduleName



-- VIEW INSTRUCTIONS


instructions : String -> Html msg
instructions md =
    div
        [ style [ "width" => "600px" ]
        ]
        [ Markdown.block md

        --, input
        --[ type_ "file"
        --, id "fileLoader"
        --, style [ "margin-left" => "1em" ]
        --]
        --[]
        ]


long : String
long =
    """

# Preview your Docs

To generate documentation for your package, run this command in the root of
your package:

```bash
elm-make --docs=documentation.json
```

That will create a file called `documentation.json`. Give me that file.

"""


short : String
short =
    """

# Preview your Docs

"""
