require_relative "./feature.rb"

module Rubiclifier
  class IdleDetector
    def self.set_idle_seconds_threshold(idle_seconds_threshold)
      @idle_seconds_threshold = idle_seconds_threshold
    end

    def self.idle_seconds_threshold
      @idle_seconds_threshold || 120
    end

    def self.is_idle?
      Feature.fail_unless_enabled(Feature::IDLE_DETECTION)
      seconds_idle = `/usr/local/sbin/sleepwatcher -g`.to_i / 10
      seconds_idle > idle_seconds_threshold
    end
  end
end
