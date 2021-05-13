
require "gobject/gtk/autorun"
require "http/server"
require "uri"
require "http/client"
require "./ui/components/Login"
require "./crymail/data.cr"

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

def login()
  # xdg-open
  Process.run("xdg-open", [REQUEST_URL])
  channel = Channel(OauthResponse).new

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
    channel.send(data)
  end
  
  address = server.bind_tcp PORT
  puts "Listening on http://#{address}"
  spawn do
    server.listen
  end

  puts "tests"
  output = channel.receive
  server.close

  puts output
  # puts "Hello"

  
end

window = Gtk::Window.new
window.title = "Box demo!"
window.connect "destroy", &->Gtk.main_quit
# window.border_width = 10

# name_container = Gtk::Box.new :vertical, spacing: 2

# name_label = Gtk::Label.new "Enter name"
# name_container.pack_start(name_label, expand: true, fill: true, padding: 10)

# name_entry = Gtk::Entry.new
# name_entry.connect("changed") { p! name_entry.text }
# name_container.pack_start(name_entry, expand: true, fill: true, padding: 10)

# name_submit = Gtk::Button.new label: "OK!"
# name_submit.connect("clicked") { puts name_submit }
# name_container.pack_start(name_submit, expand: true, fill: true, padding: 10)

# remarks_container = Gtk::Box.new :horizontal, 2

# remarks_label = Gtk::Label.new "Enter remarks"
# remarks_container.pack_start(remarks_label, expand: true, fill: true, padding: 5)

# remarks_entry = Gtk::Entry.new
# remarks_container.pack_start(remarks_entry, expand: true, fill: true, padding: 5)

# remarks_submit = Gtk::Button.new label: "Save"
# remarks_submit.on_clicked { puts "Stored remarks: #{remarks_entry.text}" }
# remarks_container.pack_start(remarks_submit, expand: true, fill: true, padding: 5)

# root = Gtk::Box.new :vertical, spacing: 2
# root.add name_container
# root.add remarks_container
# window.add root
# login = ->() {
#   puts "Hello"
# }

container = Login.render(->login)
window.add container

window.show_all

# require "log"
# require "./crymail/storage"
# require "./crymail/version"

# Log.setup(:debug)
# Logger = Log.for("crymail", :debug)
# Logger.info { "Running at version: [#{Crymail::VERSION}]"}

# # database = Storage.new("./data")
