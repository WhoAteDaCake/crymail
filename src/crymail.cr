
require "gobject/gtk"
require "http/server"
require "uri"
require "http/client"
require "log"

require "./ui/components/Login"
require "./crymail/data.cr"
require "./crymail/storage"
require "./crymail/version"
require "./crymail/auth"

Log.setup(:debug, backend: Log::IOBackend.new(dispatcher: Log::DispatchMode::Direct))
Logger = Log.for("crymail", :debug)
Logger.info { "Running at version: [#{Crymail::VERSION}]"}

storage = Storage.new("./data")
auth = Auth.new(storage)


window = Gtk::Window.new
window.title = "Box demo!"
window.connect "destroy", &->Gtk.main_quit


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

container = Login.render(->auth.login)
window.add container

window.show_all

fun main(argc: Int32, argv : UInt8**) : Int32
  Crystal.main do
    LibGtk.init pointerof(argc), pointerof(argv)

    Crystal.main_user_code(argc, argv)

    LibGtk.main
  end
end

Signal::INT.trap do
  Gtk.main_quit
  exit
end