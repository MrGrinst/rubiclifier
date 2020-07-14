require 'sinatra/base'

module Rubiclifier
  class Server < Sinatra::Base
    def self.hydrate
      raise NotImplementedError
    end

    get "/" do
      redirect("/index.html")
    end
  end
end
