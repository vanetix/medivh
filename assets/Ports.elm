port module Ports exposing (..)

import Json.Encode exposing (Value)


port updateUser : (Value -> msg) -> Sub msg


port windowKeyPress : (String -> msg) -> Sub msg


port saveToLocal : ( String, String ) -> Cmd msg


port loadFromLocal : String -> Cmd msg


port loadedUsers : (String -> msg) -> Sub msg
