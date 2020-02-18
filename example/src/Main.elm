port module Main exposing (..)

import Browser
import GoogleSignIn
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Json.Encode as E



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


id : GoogleSignIn.ClientId
id =
    GoogleSignIn.Id "421355382458-d5e1j581a9atnin2t9vfsbd62fkqkmie"


port googleSignOut : E.Value -> Cmd msg


port googleSignOutComplete : (E.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    Maybe String


init : () -> ( Model, Cmd msg )
init () =
    ( Nothing, Cmd.none )



-- UPDATE


type Msg
    = SignIn GoogleSignIn.Profile
    | BeginSignOut
    | SignOutComplete


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignIn profile ->
            ( Just profile.name, Cmd.none )

        BeginSignOut ->
            ( model, googleSignOut <| GoogleSignIn.encodeId id )

        SignOutComplete ->
            ( Nothing, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    googleSignOutComplete (\a -> SignOutComplete)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ case model of
            Just name ->
                div []
                    [ div [] [ text ("Welcome, " ++ name) ]
                    , div [] [ button [ onClick BeginSignOut ] [ text "Sign Out" ] ]
                    ]

            Nothing ->
                GoogleSignIn.view
                    [ GoogleSignIn.onSignIn SignIn
                    , GoogleSignIn.idAttr id
                    ]
        ]
