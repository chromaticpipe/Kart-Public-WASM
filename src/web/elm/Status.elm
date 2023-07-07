module Status exposing (..)

import Parser exposing ((|.), (|=), Parser, end, int, keyword, map, number, oneOf, run, spaces, succeed, symbol)


type alias ByteCount =
    Int


type alias DownloadStatus =
    { downloaded : ByteCount
    , total : ByteCount
    }


type Status
    = Downloading DownloadStatus
    | Running
    | Error
    | NotStarted
    | Nothing


downloadingData : Parser Status
downloadingData =
    map Downloading
        (succeed DownloadStatus
            |. keyword "Downloading"
            |. spaces
            |. keyword "data"
            |. symbol "..."
            |. spaces
            |. symbol "("
            |= int
            |. symbol "/"
            |= int
            |. symbol ")"
            |. end
        )


running : Parser Status
running =
    succeed Running
        |. keyword "Running"
        |. symbol "..."


parse : String -> Result (List Parser.DeadEnd) Status
parse =
    run <| oneOf [ downloadingData, running, map (\_ -> Nothing) spaces ]


toString : Status -> String
toString status =
    case status of
        Downloading { downloaded, total } ->
            "Downloading (" ++ String.fromInt downloaded ++ "/" ++ String.fromInt total ++ ")"

        Running ->
            "Running..."

        Error ->
            "Error"

        NotStarted ->
            "Not Started"

        Nothing ->
            ""
