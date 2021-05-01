require "sqlite3"
require "db"
require "log"
require "./version"

Logger = Log.for("Storage")
DB_FILE="data.db"

class Storage
  @conn : DB::Database 

  def initialize(path : String)
    path = Path[path].join(DB_FILE).expand
    File.delete(path)
    
    init = false
    if !File.exists?(path)
      Logger.info { "Database not found assuming fresh start" }
      init = true
      File.open(path, "w") do |file| end
    end
    
    Logger.info { "Opening sqllite3 connection at #{path.to_s}"}
    @conn = DB.open "sqlite3://#{path.to_s}"
    if init
      setup()
    end
  end

  def setup()
    Logger.info { "Running database setup" }
    Logger.info { "Creating tables" }
    @conn.exec "create table config (key text, value text)"


    args = [] of DB::Any
    args << Crymail::VERSION
    @conn.exec "insert into config (key, value) values ('version', ?)", args: args
  end

end