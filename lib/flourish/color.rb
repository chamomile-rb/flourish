# frozen_string_literal: true

module Flourish
  module Color
    def self.parse(value)
      return NoColor.new if value.nil? || value == ""

      return parse_hex(value) if value.is_a?(String) && value.start_with?("#")

      code = value.to_i
      return ANSIColor.new(code) if code.between?(0, 15)
      return ANSI256Color.new(code) if code.between?(16, 255)

      NoColor.new
    end

    def self.parse_hex(hex)
      hex = hex.delete_prefix("#")
      case hex.length
      when 3
        r = (hex[0] * 2).to_i(16)
        g = (hex[1] * 2).to_i(16)
        b = (hex[2] * 2).to_i(16)
        TrueColor.new(r, g, b)
      when 6
        r = hex[0..1].to_i(16)
        g = hex[2..3].to_i(16)
        b = hex[4..5].to_i(16)
        TrueColor.new(r, g, b)
      else
        NoColor.new
      end
    end

    private_class_method :parse_hex

    class NoColor
      def fg_sequence = nil
      def bg_sequence = nil
      def no_color? = true
    end

    class ANSIColor
      attr_reader :code

      def initialize(code)
        @code = code
      end

      def fg_sequence
        if @code < 8
          (30 + @code).to_s
        else
          (90 + @code - 8).to_s
        end
      end

      def bg_sequence
        if @code < 8
          (40 + @code).to_s
        else
          (100 + @code - 8).to_s
        end
      end

      def no_color? = false
    end

    class ANSI256Color
      attr_reader :code

      def initialize(code)
        @code = code
      end

      def fg_sequence
        "38;5;#{@code}"
      end

      def bg_sequence
        "48;5;#{@code}"
      end

      def no_color? = false
    end

    class TrueColor
      attr_reader :r, :g, :b

      def initialize(r, g, b)
        @r = r
        @g = g
        @b = b
      end

      def fg_sequence
        "38;2;#{@r};#{@g};#{@b}"
      end

      def bg_sequence
        "48;2;#{@r};#{@g};#{@b}"
      end

      def no_color? = false
    end

    # Named ANSI color constants (0-15)
    BLACK = ANSIColor.new(0)
    RED = ANSIColor.new(1)
    GREEN = ANSIColor.new(2)
    YELLOW = ANSIColor.new(3)
    BLUE = ANSIColor.new(4)
    MAGENTA = ANSIColor.new(5)
    CYAN = ANSIColor.new(6)
    WHITE = ANSIColor.new(7)
    BRIGHT_BLACK = ANSIColor.new(8)
    BRIGHT_RED = ANSIColor.new(9)
    BRIGHT_GREEN = ANSIColor.new(10)
    BRIGHT_YELLOW = ANSIColor.new(11)
    BRIGHT_BLUE = ANSIColor.new(12)
    BRIGHT_MAGENTA = ANSIColor.new(13)
    BRIGHT_CYAN = ANSIColor.new(14)
    BRIGHT_WHITE = ANSIColor.new(15)
  end
end
