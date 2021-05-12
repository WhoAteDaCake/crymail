require "gobject/gtk/autorun"

module Login
  def self.render(on_click)
    container = Gtk::Box.new :vertical, spacing: 0
    submit = Gtk::Button.new label: "Login"
    unless on_click.nil?
      # submit.connect("clicked") { puts "clicked"}
      # submit.connect("clicked") { puts "test1"}
      submit.connect("clicked", on_click)
    end
    container.pack_start(submit, expand: true, fill: true, padding: 10)
    container
  end
end