module Rubiclifier
  class Setting
    attr_reader :key, :label, :explanation, :is_secret, :nullable
    private :key, :label, :explanation, :is_secret, :nullable

    def initialize(key, label, explanation: nil, is_secret: false, nullable: false)
      @key = key
      @label = label
      @explanation = explanation
      @is_secret = is_secret
      @nullable = nullable
    end

    def populate
      input = nil
      loop do
        print("What's the #{label}? #{explanation_text}".blue)
        input = if is_secret
                  STDIN.noecho(&:gets).chomp.tap { puts }
                else
                  STDIN.gets.chomp
                end
        if input == ""
          input = nil
          puts("This value can't be empty.".red) unless nullable
        end
        break if input || nullable
      end
      DB.save_setting(key, input, is_secret: is_secret) unless input.nil?
    end

    def explanation_text
      if explanation.is_a?(Proc)
        "(#{explanation.call}) "
      elsif explanation
        "(#{explanation}) "
      end
    end

    def is_setup?
      DB.get_setting(key) || nullable
    end
  end
end
