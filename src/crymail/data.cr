require "json"

struct OauthResponse
  include JSON::Serializable

  property access_token : String
  property expires_in : Int64
  property id_token : String
  property refresh_token : String
  property scope : String
  property token_type : String
end