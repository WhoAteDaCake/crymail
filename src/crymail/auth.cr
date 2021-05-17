require "log"
require "json"
require "http/server"
require "uri"
require "http/client"

require "./storage"

CLIENT_ID="236467804844-87phejf0vcq86rhc93ud679b1maul3i9.apps.googleusercontent.com"
CLIENT_SECRET="vUhYtrbFHmjy4oDoJTCx9lFZ"

PORT = 9006
ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth"
TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"
SCOPES = [
  "https://mail.google.com/",
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/userinfo.profile",
].join(" ")

REQUEST_URL = URI.encode("#{ENDPOINT}?client_id=#{CLIENT_ID}&redirect_uri=http://127.0.0.1:#{PORT}&response_type=code&access_type=offline&prompt=select_account&scope=#{SCOPES}")

struct OauthResponse
  include JSON::Serializable

  property access_token : String
  property expires_in : Int64
  property id_token : String
  property refresh_token : String
  property scope : String
  property token_type : String
end

class Token
  include JSON::Serializable
  
  property internal : OauthResponse
  property expires_on : Time

  def initialize(@internal)
    @expires_on = Time.utc + Time::Span.new(seconds: @internal.expires_in)
  end

  def header()
    "#{@internal.token_type} #{@internal.access_token}"
  end
end

class Auth
  property storage : Storage
  property token : Token | Nil

  def initialize(@storage)
  end

  def retrieve_auth_response()
    channel = Channel(Token).new

    server = HTTP::Server.new do |context|
      code = context.request.query_params["code"]
      context.response.content_type = "text/plain"
      context.response.print "Please close the window and go back to the Application"

      params = HTTP::Params.new
      params.add("client_id", CLIENT_ID)
      params.add("client_secret", CLIENT_SECRET)
      params.add("code", code)
      params.add("redirect_uri", "http://127.0.0.1:#{PORT}")
      params.add("grant_type", "authorization_code")
      url = "#{TOKEN_ENDPOINT}?#{params.to_s}"

      response = HTTP::Client.post url
      data = OauthResponse.from_json(response.body)
      channel.send(Token.new(data))
    end
    
    address = server.bind_tcp PORT
    spawn do
      server.listen
    end

    output = channel.receive
    puts "Output"
    p! output
    server.close
    output
  end

  def save_token(token : Token)
    @token = token
    args = [] of DB::Any
    args << token.to_json()
    @storage.conn.exec "
      insert into config (key, value)
      values ('token', ?)
    ", args: args
  end

  def from_storage()
    token = nil
    @storage.conn.query "
      select value
      from config
      where key = 'token'
    " do | rs |
      rs.each do
        token = Token.from_json(rs.read(String))
      end
    end
    token
  end

  def login()
    @token = from_storage()
    if @token.nil?
      # TODO: support different problems ?
      Process.run("xdg-open", [REQUEST_URL])
      token = retrieve_auth_response()
      save_token(token)
    end
  end

end