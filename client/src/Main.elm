module Main exposing (..)

import App exposing (..)
import Navigation exposing (Location, programWithFlags)
import Types exposing (..)


main : Program String Model Msg
main =
    programWithFlags (\l -> NoOp)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
