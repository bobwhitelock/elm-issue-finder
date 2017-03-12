module App exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing ((<?>))
import Http
import RemoteData exposing (WebData, RemoteData(..))


type alias Model =
    { message : String
    , logo : String
    , state : State
    }


type State
    = Unauthenticated
    | Authenticated AuthenticatedState


type alias AuthenticatedState =
    { username : String
    , issues : WebData String
    }


init : String -> Location -> ( Model, Cmd Msg )
init pathFlag location =
    let
        maybeUsername =
            usernameFromUrl location

        currentState =
            case maybeUsername of
                Nothing ->
                    Unauthenticated

                Just username ->
                    Authenticated
                        { username = username
                        , issues = RemoteData.Loading
                        }

        initialModel =
            { message = "Your Elm App is working!"
            , logo = pathFlag
            , state = currentState
            }

        initialCmd =
            case maybeUsername of
                Nothing ->
                    Cmd.none

                Just username ->
                    getIssues
    in
        ( initialModel
        , initialCmd
        )


usernameFromUrl : Location -> Maybe String
usernameFromUrl location =
    Maybe.withDefault Nothing
        (UrlParser.parsePath
            (UrlParser.top <?> UrlParser.stringParam "authenticated_github_user")
            location
        )


getIssues : Cmd Msg
getIssues =
    Http.getString getIssuesUrl
        |> RemoteData.sendRequest
        |> Cmd.map IssuesResponse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            identityUpdate model

        StartAuthentication ->
            ( model, Navigation.load authenticationUrl )

        IssuesResponse issues ->
            case model.state of
                Authenticated state ->
                    ( { model
                        | state = Authenticated (setIssues state issues)
                      }
                    , Cmd.none
                    )

                _ ->
                    identityUpdate model


identityUpdate : Model -> ( Model, Cmd Msg )
identityUpdate model =
    ( model, Cmd.none )


setIssues : AuthenticatedState -> WebData String -> AuthenticatedState
setIssues state issuesResponse =
    { state | issues = issuesResponse }


authenticationUrl =
    serverUrl ++ "/authenticate"


getIssuesUrl =
    serverUrl ++ "/retrieve-issues"


serverUrl =
    "http://localhost/api"


view : Model -> Html Msg
view model =
    case model.state of
        Unauthenticated ->
            unauthenticatedPage

        Authenticated state ->
            authenticatedPage state


unauthenticatedPage : Html Msg
unauthenticatedPage =
    div []
        [ text "Need to authenticate with Github to make many API requests. Click to begin:"
        , button [ onClick StartAuthentication ] [ text "Start" ]
        ]


authenticatedPage : AuthenticatedState -> Html Msg
authenticatedPage state =
    div []
        [ text ("Hi " ++ state.username ++ "!")
        , div [] [ (displayIssuesData state) ]
        ]


displayIssuesData : AuthenticatedState -> Html Msg
displayIssuesData state =
    case state.issues of
        NotAsked ->
            span [] [ text "Initializing..." ]

        Loading ->
            span [] [ text "Loading issues..." ]

        Failure error ->
            span [] [ text ("Error: " ++ toString error) ]

        Success issues ->
            span [] [ text issues ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
