module Rubiclifier
  module Feature
    BACKGROUND = "BACKGROUND"
    DATABASE = "DATABASE"
    NOTIFICATIONS = "NOTIFICATIONS"
    IDLE_DETECTION = "IDLE_DETECTION"
    SERVER = "SERVER"

    def self.set_enabled(features)
      @enabled = features
    end

    def self.enabled?(feature)
      @enabled.include?(feature)
    end

    def self.fail_unless_enabled(feature)
      raise "Looks like you're trying to use feature 'Rubiclifier::Feature::#{feature}' without specifying it in your features." unless Feature.enabled?(feature)
    end
  end
end
