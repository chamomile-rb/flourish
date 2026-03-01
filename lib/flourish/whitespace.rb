# frozen_string_literal: true

module Flourish
  module Whitespace
    class << self
      def fill(width, char = " ")
        return "" if width <= 0

        char * width
      end
    end
  end
end
