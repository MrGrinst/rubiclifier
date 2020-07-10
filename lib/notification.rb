require_relative "./feature.rb"

module Rubiclifier
  class Notification
    attr_reader :title, :message, :subtitle, :icon, :url
    private :title, :message, :subtitle, :icon, :url

    def initialize(title, message, subtitle = nil, icon = nil, url = nil)
      Feature.fail_unless_enabled(Feature::NOTIFICATIONS)
      @title = title
      @message = message
      @subtitle = subtitle
      @icon = icon
      @url = url
    end

    def send
      args = {
        "title" => title,
        "message" => message,
        "subtitle" => subtitle,
        "appIcon" => icon,
        "open" => url
      }
      all_args = args.keys.reduce("") do |arg_string, key|
        if args[key]
          arg_string += " -#{key} '#{args[key]}'"
        end
        arg_string
      end
      system("/usr/local/bin/terminal-notifier #{all_args}")
    end
  end
end
