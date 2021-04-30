require "sqlite3"
require "db"

DB_FILE="data.db"

class Storage
  @conn : DB::Database 

  def initialize(path : String)
    path = Path[path].join(DB_FILE).normalize
    
    init = false
    if !File.exists?(path)
      init = true
      File.open(path, "w") do |file| end
    end
    puts init
    @conn = DB.open "sqlite3://#{path.to_s}"
  end

  def setup()
    puts "hello"
  end

end