module Component.PackageDocs exposing (..)

import Dict
import Docs.Entry as Entry
import Docs.Name as Name
import Docs.Package as Docs
import Docs.Type as Type
import Html exposing (..)
import Html.Attributes exposing (..)
import Parse.Type as Type
import Regex
import Set
import String
import Utils.Markdown as Markdown


-- MODEL


type Model
    = Failed String
    | ParsedDocs (Info Type.Type)


type alias Info tipe =
    { name : String
    , nameDict : Name.Dictionary
    , chunks : List (Chunk tipe)
    }


type Chunk tipe
    = Markdown String
    | Entry (Entry.Model tipe)



-- INIT


init : Docs.Package -> String -> ( Model, Cmd Msg )
init docs moduleName =
    case Dict.get moduleName docs of
        Just moduleDocs ->
            let
                chunks =
                    toChunks moduleDocs

                newChunks =
                    typeParse chunks
            in
            ( ParsedDocs (Info moduleName (toNameDict docs) newChunks)
            , Cmd.none
            )

        Nothing ->
            ( Failed ("Could not find module '" ++ moduleName ++ "'")
            , Cmd.none
            )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )


toNameDict : Docs.Package -> Name.Dictionary
toNameDict pkg =
    Dict.map (\_ modul -> Set.fromList (Dict.keys modul.entries)) pkg


typeParse : List (Chunk String) -> List (Chunk Type.Type)
typeParse chunks =
    List.map (chunkMap stringToType) chunks



-- EFFECTS


chunkMap : (a -> b) -> Chunk a -> Chunk b
chunkMap func chunk =
    case chunk of
        Markdown md ->
            Markdown md

        Entry entry ->
            Entry (Entry.map func entry)


stringToType : String -> Type.Type
stringToType str =
    case Type.parse str of
        Ok tipe ->
            tipe

        Err _ ->
            Type.Var str



-- VIEW


(=>) =
    (,)


view : Model -> Html msg
view model =
    div [ class "entry-list" ] <|
        case model of
            Failed httpError ->
                [ p [] [ text "Documentation did not load." ]
                , p [] [ text (toString httpError) ]
                ]

            ParsedDocs { name, nameDict, chunks } ->
                h1 [ class "entry-list-title" ] [ text name ]
                    :: List.map (viewChunk (Entry.typeView nameDict)) chunks


viewChunk : (Entry.Model tipe -> Html msg) -> Chunk tipe -> Html msg
viewChunk entryView chunk =
    case chunk of
        Markdown md ->
            span [ class "markdown-entry" ] [ Markdown.block md ]

        Entry entry ->
            entryView entry



-- MAKE CHUNKS


toChunks : Docs.Module -> List (Chunk String)
toChunks moduleDocs =
    case String.split "\n@docs " moduleDocs.comment of
        [] ->
            Debug.crash "Expecting some documented functions in this module!"

        firstChunk :: rest ->
            Markdown firstChunk
                :: List.concatMap (subChunks moduleDocs) rest


subChunks : Docs.Module -> String -> List (Chunk String)
subChunks moduleDocs postDocs =
    subChunksHelp moduleDocs (String.split "," postDocs)


subChunksHelp : Docs.Module -> List String -> List (Chunk String)
subChunksHelp moduleDocs parts =
    case parts of
        [] ->
            []

        rawPart :: remainingParts ->
            let
                part =
                    String.trim rawPart
            in
            case isValue part of
                Just valueName ->
                    toEntry moduleDocs valueName
                        :: subChunksHelp moduleDocs remainingParts

                Nothing ->
                    let
                        trimmedPart =
                            String.trimLeft rawPart
                    in
                    case String.words trimmedPart of
                        [] ->
                            [ Markdown (String.join "," parts) ]

                        token :: _ ->
                            case isValue token of
                                Just valueName ->
                                    [ toEntry moduleDocs valueName
                                    , trimmedPart
                                        :: remainingParts
                                        |> String.join ","
                                        |> String.dropLeft (String.length token)
                                        |> Markdown
                                    ]

                                Nothing ->
                                    [ Markdown (String.join "," parts) ]


var : Regex.Regex
var =
    Regex.regex "^[a-zA-Z0-9_']+$"


operator : Regex.Regex
operator =
    Regex.regex "^\\([^a-zA-Z0-9]+\\)$"


isValue : String -> Maybe String
isValue str =
    if Regex.contains var str then
        Just str
    else if Regex.contains operator str then
        Just (String.dropLeft 1 (String.dropRight 1 str))
    else
        Nothing


toEntry : Docs.Module -> String -> Chunk String
toEntry moduleDocs name =
    case Dict.get name moduleDocs.entries of
        Nothing ->
            Debug.crash ("docs have been corrupted, could not find " ++ name)

        Just entry ->
            Entry entry
