module App exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing ((<?>))


type alias Model =
    { message : String
    , logo : String
    , authenticatedUserName : Maybe String
    }


init : String -> Location -> ( Model, Cmd Msg )
init pathFlag location =
    ( { message = "Your Elm App is working!"
      , logo = pathFlag
      , authenticatedUserName = userNameFromUrl location
      }
    , Cmd.none
    )


userNameFromUrl : Location -> Maybe String
userNameFromUrl location =
    Maybe.withDefault Nothing
        (UrlParser.parsePath
            (UrlParser.top <?> UrlParser.stringParam "authenticated_github_user")
            location
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartAuthentication ->
            ( model, Navigation.load authenticationUrl )

        NoOp ->
            ( model, Cmd.none )


authenticationUrl =
    "http://localhost:4567/authenticate"


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
