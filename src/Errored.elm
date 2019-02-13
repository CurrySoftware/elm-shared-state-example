module Errored exposing (PageLoadError, pageLoadError, view)

import Browser
import Element exposing (Element, text)


type PageLoadError
    = PageLoadError Model


type alias Model =
    { errorMessage : String }


pageLoadError : String -> PageLoadError
pageLoadError errorMessage =
    PageLoadError { errorMessage = errorMessage }


view : PageLoadError -> Element msg
view (PageLoadError model) =
    text model.errorMessage
