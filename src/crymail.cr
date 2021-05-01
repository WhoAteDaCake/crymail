require "log"
require "./storage"
require "./version"

Logger = Log.for("crymail")
Logger.info { "Running at version: [#{Crymail::VERSION}]"}

database = Storage.new("./data")