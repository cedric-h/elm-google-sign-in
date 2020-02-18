module GoogleSignIn exposing (..)

import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes exposing (property)
import Html.Styled.Events as Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ATTRIBUTE WRAPPER


type Attribute msg
    = Attr (Html.Attribute msg)


unattr : Attribute msg -> Html.Attribute msg
unattr (Attr a) =
    a



-- PROPERTIES


type ClientId
    = Id String


encodeId : ClientId -> Value
encodeId (Id id) =
    Encode.string id


idAttr : ClientId -> Attribute msg
idAttr =
    encodeId >> property "clientId" >> Attr



-- LISTENERS


onSignIn : (Profile -> msg) -> Attribute msg
onSignIn tagger =
    Decode.at [ "target", "profile" ] profileDecoder
        |> Decode.map tagger
        |> on "signIn"
        |> Attr



-- PROFILE


type alias Profile =
    { id : String
    , idToken : String
    , name : String
    , givenName : String
    , familyName : String
    , imageUrl : String
    , email : Maybe String
    }


profileDecoder : Decoder Profile
profileDecoder =
    Decode.map7
        Profile
        (Decode.field "id" Decode.string)
        (Decode.field "idToken" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "givenName" Decode.string)
        (Decode.field "familyName" Decode.string)
        (Decode.field "imageUrl" Decode.string)
        (Decode.field "email" (Decode.nullable Decode.string))



-- VIEW


styledView : List (Attribute msg) -> Html msg
styledView attributes =
    Html.node "google-signin-button" (List.map unattr attributes) []


view attributes =
    Html.toUnstyled <| styledView attributes
