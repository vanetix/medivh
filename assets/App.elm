module App exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (..)
import Json.Encode
import List
import Ports
import Set exposing (Set)
import Task


type alias Flags =
    { users : Json.Encode.Value
    }


type UserStatus
    = Active
    | Away
    | Unknown


type ActiveView
    = UserListView
    | SaveUsersView


type alias UserAttributes =
    { name : String
    , avatar : String
    , status : UserStatus
    , status_emoji : Maybe String
    , status_text : Maybe String
    }


type alias Model =
    { users : Dict String UserAttributes
    , savedUsers : Set String
    , currentView : ActiveView
    , search : Maybe String
    , errorMsg : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        users =
            decodeValue decoder flags.users
                |> Result.withDefault Dict.empty
    in
        ( Model users Set.empty UserListView Nothing Nothing, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.updateUser UpdateUser
        , Ports.loadedUsers LoadedSavedUsers
        ]


type Msg
    = UpdateUser Json.Encode.Value
    | SetUsers Json.Encode.Value
    | SaveUsers
    | LoadSavedUsers
    | LoadedSavedUsers String
    | SearchUser String
    | ChangeView ActiveView
    | Clear


decoder : Decoder (Dict String UserAttributes)
decoder =
    dict <|
        map5 UserAttributes
            (field "name" string)
            (field "avatar" string)
            (field "status" decodeStatus)
            (field "status_text" (nullable string))
            (field "status_emoji" (nullable string))


decodeStatus : Decoder UserStatus
decodeStatus =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "active" ->
                        Json.Decode.succeed Active

                    "away" ->
                        Json.Decode.succeed Away

                    _ ->
                        Json.Decode.succeed Unknown
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Clear ->
            ( { model | search = Nothing }, Cmd.none )

        SetUsers data ->
            case decodeValue decoder data of
                Ok results ->
                    ( { model | users = results }, Cmd.none )

                Err msg ->
                    ( { model | errorMsg = Just msg }, Cmd.none )

        SaveUsers ->
            ( model, Cmd.none )

        LoadSavedUsers ->
            ( model, Ports.loadFromLocal "users" )

        LoadedSavedUsers userIds ->
            ( model, Cmd.none )

        UpdateUser data ->
            case decodeValue decoder data of
                Ok user ->
                    let
                        users =
                            Dict.union user model.users
                    in
                        ( { model | users = users }, Cmd.none )

                Err msg ->
                    ( { model | errorMsg = Just msg }, Cmd.none )

        SearchUser str ->
            ( { model | search = Just str }, Cmd.none )

        ChangeView view ->
            let
                cmds =
                    case view of
                        SaveUsersView ->
                            Task.perform (always SaveUsers) (Task.succeed never)

                        _ ->
                            Cmd.none
            in
                ( { model | currentView = view }, cmds )


view : Model -> Html Msg
view model =
    main_ [ attribute "role" "main" ]
        [ headerView model.search
        , mainView model
        ]


mainView : Model -> Html Msg
mainView model =
    case model.currentView of
        SaveUsersView ->
            div [ class "user-chooser" ] []

        UserListView ->
            div [ class "user-grid" ]
                [ ol []
                    (Dict.values model.users
                        |> (sortedUsers >> List.map (userView model.search))
                    )
                ]


headerView : Maybe String -> Html Msg
headerView maybeSearch =
    header [ class "top-bar" ]
        [ nav []
            [ ul []
                [ li []
                    [ a
                        [ class "edit"
                        , onClick (ChangeView SaveUsersView)
                        , property "innerHTML" <| Json.Encode.string "&#x270F;"
                        ]
                        []
                    ]
                ]
            ]
        ]


userView : Maybe String -> UserAttributes -> Html Msg
userView maybeSearch user =
    li []
        [ div
            [ class "user"
            , class (userClass user)
            , class (userHighlightClass maybeSearch user.name)
            , title user.name
            ]
            [ div [ class "user__avatar" ] [ img [ src user.avatar ] [] ]
            , div [ class "user__details" ]
                [ p [] [ text user.name ]
                ]
            ]
        ]


userClass : UserAttributes -> String
userClass user =
    case user.status of
        Active ->
            "user--active"

        Away ->
            "user--away"

        _ ->
            ""


userHighlightClass : Maybe String -> String -> String
userHighlightClass maybeSearch name =
    case maybeSearch of
        Just str ->
            let
                contained =
                    String.toLower name
                        |> String.contains (String.toLower str)
            in
                if contained == True && String.length str > 2 then
                    "user--highlight"
                else
                    ""

        Nothing ->
            ""


sortedUsers : List UserAttributes -> List UserAttributes
sortedUsers users =
    List.sortBy .name users
