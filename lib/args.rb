module Rubiclifier
  class Args
    attr_reader :args
    private :args

    def initialize(args)
      @args = args
    end

    def command
      args[0]
    end

    def subcommand
      args[1]
    end

    def none?
      args.length == 0
    end

    def string(full_name, aliased = nil)
      pos = args.find_index { |a| a == "--#{full_name}" || a == "-#{aliased}" }
      pos && args[pos + 1]
    end

    def number(full_name, aliased = nil)
      string(full_name, aliased)&.to_i
    end

    def boolean(full_name, aliased = nil)
      !!args.find_index { |a| a == "--#{full_name}" || a == "-#{aliased}" }
    end
  end
end
