require "io/console"
require_relative "./args.rb"
require_relative "./colorized_strings.rb"
require_relative "./setting.rb"

module Rubiclifier
  class BaseApplication
    attr_reader :args, :executable_name
    private :args, :executable_name

    def initialize(args, executable_name)
      @args = Args.new(args)
      @executable_name = executable_name
      Feature.set_enabled(all_features)
      DB.hydrate(data_directory, migrations_location) if Feature.enabled?(Feature::DATABASE)
    end

    def call
      show_help if args.command == "help" || args.boolean("help", "h")
      setup_or_fail if needs_setup?
      if Feature.enabled?(Feature::SERVER)
        run_server
      else
        run_application
      end
    end

    def show_help
      raise NotImplementedError
    end

    def run_server
      raise NotImplementedError
    end

    def run_application
      raise NotImplementedError
    end

    def run_server
      server_class.hydrate
      server_class.run!
    end

    def additional_setup
    end

    def post_setup_message
    end

    def not_setup
    end

    def features
      []
    end

    def settings
      []
    end

    def data_directory
      raise NotImplementedError if Feature.enabled?(Feature::DATABASE)
    end

    def migrations_location
      nil
    end

    def brew_dependencies
      []
    end

    private

    def all_brew_dependencies
      @abd ||= [
        ("sqlite" if Feature.enabled?(Feature::DATABASE)),
        ("terminal-notifier" if Feature.enabled?(Feature::NOTIFICATIONS)),
        ("sleepwatcher" if Feature.enabled?(Feature::IDLE_DETECTION))
      ].concat(brew_dependencies).compact
    end

    def brew_dependencies_installed?
      all_brew_dependencies.all? do |dep|
        system("/usr/local/bin/brew list #{dep} &> /dev/null")
      end
    end

    def brew_installed_or_fail
      unless system("which brew &> /dev/null")
        puts
        puts("You must install Homebrew in order to install these dependencies: #{all_brew_dependencies.join(", ")}".red)
        puts("Go to https://brew.sh/")
        exit
      end
    end

    def all_features
      [
        (Feature::DATABASE if !settings.empty?)
      ].concat(features).compact.uniq
    end

    def needs_setup?
      !all_brew_dependencies.empty? || !settings.empty? || Feature.enabled?(Feature::BACKGROUND)
    end

    def setup_or_fail
      if args.command == "setup" || args.boolean("setup", "s")
        unless all_brew_dependencies.empty?
          brew_installed_or_fail
          puts("Installing brew dependencies...")
          system("brew install #{all_brew_dependencies.join(" ")}")
        end

        puts

        settings.each do |s|
          s.populate
        end

        additional_setup

        puts

        if Feature.enabled?(Feature::BACKGROUND)
          setup_as_background_service
        else
          puts("Finished setup! Run with `".green + "#{executable_name}" + "`".green)
          post_setup_message
        end
        exit
      elsif !settings.all?(&:is_setup?) || !brew_dependencies_installed?
        not_setup
        puts
        puts("Oops! You must finish setup first.".red)
        puts("  `".red + "#{executable_name} --setup" + "`".red)
        exit
      end
    end

    def setup_as_background_service
      puts("It's recommended that you set this up as a system service with serviceman. You can check it out here: https://git.rootprojects.org/root/serviceman".yellow)
      puts("Set #{executable_name} to run on startup with `".yellow + "serviceman add --name #{executable_name} #{executable_name}" + "`".yellow)
      puts
      print("Would you like this script to set it up for you? (y/n) ")
      if STDIN.gets.chomp.downcase == "y"
        unless system("ls \"$HOME/.local/bin/serviceman\" &> /dev/null")
          puts "Installing serviceman..."
          system("-sL https://webinstall.dev/serviceman | bash")
        end
        puts "Adding #{executable_name} as a service..."
        system("$HOME/.local/bin/serviceman add --name #{executable_name} #{executable_name}")
        puts
        puts("Finished setup! The service is set to run in the background!".green)
        post_setup_message
      else
        puts
        puts("Finished setup!".green)
        post_setup_message
      end
    end
  end
end
