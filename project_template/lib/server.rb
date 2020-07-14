require "rubiclifier"

class Server < Rubiclifier::Server
  def self.hydrate
    set :public_folder, "#{File.expand_path(File.dirname(__FILE__) + "/..")}/public"
    set :port, 5000
  end
end
