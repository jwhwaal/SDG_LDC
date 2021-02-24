library(httr)
library(jsonlite)
library(curl)


add_headers(.headers = c("API-KEY = AhhR3-0hu4e7JNQIMxLlgQYT8Jg0WksHFNK--fPXWkg", "TOKEN = jwfPDUYvU2UY0LNHsfgeNode1mXnJElJ2w-9Vxxp-Ho"))
add_headers(API-KEY: "AhhR3-0hu4e7JNQIMxLlgQYT8Jg0WksHFNK--fPXWkg", TOKEN: "jwfPDUYvU2UY0LNHsfgeNode1mXnJElJ2w-9Vxxp-Ho" )

r <- GET("https://old.business-humanrights.org/api/v1/stories/headers",
         query = list(page=0, langcode="en"))
r
         


r         

r <- fromJSON(rawToChar(r$content))
r$response


GET /api/v1/path/to/resource?param1=something&param2=somethingelse
Host: business-humanrights.org
Content-Type: application/json
Accept: application/json
API-KEY: YOUR-API-KEY-HERE
TOKEN: YOUR-TOKEN-HERE