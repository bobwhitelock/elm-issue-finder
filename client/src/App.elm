module App exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing ((<?>))
import Http
import RemoteData exposing (WebData)


type alias Model =
    { message : String
    , logo : String
    , authenticatedUserName : Maybe String
    , issues : Maybe (WebData String)
    }


init : String -> Location -> ( Model, Cmd Msg )
init pathFlag location =
    let
        initialModel =
            { message = "Your Elm App is working!"
            , logo = pathFlag
            , authenticatedUserName = userNameFromUrl location
            , issues = Nothing
            }
    in
        ( initialModel
        , getIssuesIfAuthenticated initialModel
        )


userNameFromUrl : Location -> Maybe String
userNameFromUrl location =
    Maybe.withDefault Nothing
        (UrlParser.parsePath
            (UrlParser.top <?> UrlParser.stringParam "authenticated_github_user")
            location
        )


getIssuesIfAuthenticated : Model -> Cmd Msg
getIssuesIfAuthenticated model =
    case model.authenticatedUserName of
        Nothing ->
            Cmd.none

        Just userName ->
            Http.getString getIssuesUrl
                |> RemoteData.sendRequest
                |> Cmd.map IssuesResponse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        StartAuthentication ->
            ( model, Navigation.load authenticationUrl )

        IssuesResponse issues ->
            ( { model | issues = Just issues }, Cmd.none )


authenticationUrl =
    serverUrl ++ "/authenticate"


getIssuesUrl =
    serverUrl ++ "/retrieve-issues"


serverUrl =
    "http://localhost/api"


view : Model -> Html Msg
view model =
    case model.authenticatedUserName of
        Nothing ->
            div []
                [ text "Need to authenticate with Github to make many API requests. Click to begin:"
                , button [ onClick StartAuthentication ] [ text "Start" ]
                ]

        Just userName ->
            div [] [ text ("Hi " ++ userName ++ "!") ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
