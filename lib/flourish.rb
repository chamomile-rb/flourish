# frozen_string_literal: true

require_relative "flourish/version"
require_relative "flourish/ansi"
require_relative "flourish/color"
require_relative "flourish/color_profile"
require_relative "flourish/wrap"
require_relative "flourish/whitespace"
require_relative "flourish/border"
require_relative "flourish/align"
require_relative "flourish/join"
require_relative "flourish/place"
require_relative "flourish/style"

module Flourish
  # Position constants
  TOP = 0.0
  LEFT = 0.0
  CENTER = 0.5
  BOTTOM = 1.0
  RIGHT = 1.0

  class << self
    def width(str)
      ANSI.printable_width(str)
    end

    def height(str)
      ANSI.height(str)
    end

    def size(str)
      ANSI.size(str)
    end

    def join_horizontal(position, *strs)
      Join.horizontal(position, *strs)
    end

    def join_vertical(position, *strs)
      Join.vertical(position, *strs)
    end

    def place(width, height, h_pos, v_pos, str)
      Place.place(width, height, h_pos, v_pos, str)
    end

    def place_horizontal(width, pos, str)
      Place.place_horizontal(width, pos, str)
    end

    def place_vertical(height, pos, str)
      Place.place_vertical(height, pos, str)
    end
  end
end
