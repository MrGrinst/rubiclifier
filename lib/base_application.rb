require "io/console"
require_relative "./args.rb"
require_relative "./colorized_strings.rb"
require_relative "./setting.rb"

module Rubiclifier
  class BaseApplication
    attr_reader :args
    private :args

    def initialize(args)
      @args = Args.new(args)
      DB.hydrate(data_directory, migrations_location)
    end

    def call
      show_help if args.command == "help" || args.boolean("help", "h")
      setup_or_fail
      run_application
    end

    def show_help
      raise NotImplementedError
    end

    def run_application
      raise NotImplementedError
    end

    def additional_setup
    end

    def not_setup
    end

    def is_background_service?
      raise NotImplementedError
    end

    def sends_notifications?
      raise NotImplementedError
    end

    def settings
      raise NotImplementedError
    end

    def executable_name
      raise NotImplementedError
    end

    def data_directory
      raise NotImplementedError
    end

    def migrations_location
      nil
    end

    def brew_dependencies
      []
    end

    def setup_or_fail
      if args.command == "setup" || args.boolean("setup", "s")
        puts("Installing brew dependencies...")
        all_brew_dependencies = [
          "sqlite",
          ("terminal-notifier" if sends_notifications?)
        ].concat(brew_dependencies).compact
        system("brew install #{all_brew_dependencies.join(" ")}")

        puts

        settings.each do |s|
          s.populate
        end

        additional_setup

        puts

        if is_background_service?
          setup_as_background_service
        else
          puts("Finished setup! Run with `#{executable_name}`".green)
        end
        exit
      end

      unless settings.all?(&:is_setup?)
        not_setup
        puts
        puts("Oops! You must finish setup first by running with the `--setup` option.".red)
        puts("  `#{executable_name} --setup`".red)
        exit
      end
    end

    def setup_as_background_service
      puts("It's recommended that you set this up as a system service with serviceman. You can check it out here: https://git.rootprojects.org/root/serviceman".blue)
      puts("Set #{executable_name} to run on startup with `serviceman add --name #{executable_name} #{executable_name}`".blue)
      puts
      print("Would you like this script to set it up for you? (y/n) ")
      if STDIN.gets.chomp.downcase == "y"
        puts "Installing serviceman..."
        system("curl -sL https://webinstall.dev/serviceman | bash")
        puts "Adding #{executable_name} as a service..."
        system("serviceman add --name #{executable_name} #{executable_name}")
        puts
        puts("Finished setup! The service is set to run in the background!".green)
      else
        puts
        puts("Finished setup!".green)
      end
    end
  end
end
