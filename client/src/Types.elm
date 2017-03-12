module Types exposing (..)

import RemoteData exposing (WebData)


type Msg
    = NoOp
    | StartAuthentication
    | IssuesResponse (WebData String)
