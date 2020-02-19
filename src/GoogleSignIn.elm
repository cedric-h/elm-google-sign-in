module GoogleSignIn exposing
    ( view, styledView
    , Attribute
    , idAttr
    , onSignIn
    , Profile, ClientId
    )

{-| Elm bindings to the "Sign in With Google" widget

See the github for more information: <https://github.com/cedric-h/elm-google-sign-in>


## View

@docs view, styledView


## Attribute Wrapper

@docs Attribute


## Properties

@docs idAttr


## Listeners

@docs onSignIn


## Supporting Types

@docs Profile, ClientId

-}

import Html as PlainHtml
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes exposing (property)
import Html.Styled.Events as Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ATTRIBUTE WRAPPER


{-| Like a normal HTML Attribute, but these can only apply to Google Sign in Buttons
-}
type Attribute msg
    = Attr (Html.Attribute msg)


unattr : Attribute msg -> Html.Attribute msg
unattr (Attr a) =
    a



-- PROPERTIES


{-| What Google uses to keep track of your application
-}
type ClientId
    = Id String


encodeId : ClientId -> Value
encodeId (Id id) =
    Encode.string id


{-| Supply the ClientId for the application this button should sign in to.
-}
idAttr : ClientId -> Attribute msg
idAttr =
    encodeId >> property "clientId" >> Attr



-- LISTENERS


{-| Respond to when the user completes signing in through Google.
-}
onSignIn : (Profile -> msg) -> Attribute msg
onSignIn tagger =
    Decode.at [ "target", "profile" ] profileDecoder
        |> Decode.map tagger
        |> on "signIn"
        |> Attr



-- PROFILE


{-| All of the important information Google stores about a user.
The `idToken` is what should be sent back to your server for authentication purposes.
The `email` field is only present if your clientId has the right scopes.
-}
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


{-| Yields a Google sign in button
intended for use with rtfeldman/elm-css
-}
styledView : List (Attribute msg) -> Html msg
styledView attributes =
    Html.node "google-signin-button" (List.map unattr attributes) []


{-| Yields a Google sign in button
intended for use with elm/html
-}
view : List (Attribute msg) -> PlainHtml.Html msg
view attributes =
    Html.toUnstyled <| styledView attributes
