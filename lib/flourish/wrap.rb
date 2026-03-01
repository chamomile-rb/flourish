# frozen_string_literal: true

module Flourish
  module Wrap
    class << self
      def word_wrap(str, width)
        return str if width <= 0

        lines = str.split("\n", -1)
        result = []

        lines.each do |line|
          result.concat(wrap_line(line, width))
        end

        result.join("\n")
      end

      private

      def wrap_line(line, width)
        return [""] if line.empty?

        state = { result: [], current: +"", current_width: 0, active_sgr: +"" }
        i = 0
        chars = line.chars

        while i < chars.length
          seq = chars[i] == "\e" ? extract_escape(chars, i) : nil
          if seq
            state[:current] << seq
            track_sgr(state[:active_sgr], seq)
            i += seq.length
            next
          end

          ch = chars[i]
          ch_width = ANSI.printable_width(ch)
          i += 1

          if state[:current_width] + ch_width > width && state[:current_width].positive?
            emit_break(state)
            next if ch == " " # skip leading space after break
          end

          state[:current] << ch
          state[:current_width] += ch_width
        end

        close_final_line(state)
      end

      def emit_break(state)
        break_pos = find_break_pos(state[:current])

        if break_pos&.positive?
          break_at_word_boundary(state, break_pos)
        else
          force_break(state)
        end
      end

      def break_at_word_boundary(state, break_pos)
        before = state[:current][0...break_pos]
        after_start = break_pos
        after_start += 1 if state[:current][break_pos] == " "
        after = state[:current][after_start..]

        before << "\e[0m" unless state[:active_sgr].empty?
        state[:result] << before

        state[:current] = +""
        state[:current] << state[:active_sgr] unless state[:active_sgr].empty?
        state[:current] << after
        state[:current_width] = ANSI.printable_width(after)
      end

      def force_break(state)
        state[:current] << "\e[0m" unless state[:active_sgr].empty?
        state[:result] << state[:current]
        state[:current] = +""
        state[:current] << state[:active_sgr] unless state[:active_sgr].empty?
        state[:current_width] = 0
      end

      def close_final_line(state)
        state[:current] << "\e[0m" if !state[:active_sgr].empty? && !state[:current].empty?
        state[:result] << state[:current]
        state[:result]
      end

      def extract_escape(chars, start)
        return nil unless chars[start] == "\e"

        seq = +"\e"
        i = start + 1
        return nil if i >= chars.length

        if chars[i] == "["
          seq << "["
          i += 1
          while i < chars.length && chars[i].match?(/[0-9;]/)
            seq << chars[i]
            i += 1
          end
          if i < chars.length && chars[i].match?(/[A-Za-z]/)
            seq << chars[i]
            return seq
          end
        end

        nil
      end

      def track_sgr(active_sgr, seq)
        if ["\e[0m", "\e[m"].include?(seq)
          active_sgr.clear
        elsif seq.match?(/\A\e\[\d/)
          if active_sgr.empty?
            active_sgr.replace(seq)
          else
            active_sgr.replace("#{active_sgr.delete_suffix("\e[0m")}#{seq}")
          end
        end
      end

      def find_break_pos(str)
        pos = nil
        i = 0
        chars = str.chars
        while i < chars.length
          if chars[i] == "\e"
            esc = extract_escape(chars, i)
            if esc
              i += esc.length
              next
            end
          end
          pos = i if [" ", "-"].include?(chars[i])
          i += 1
        end
        pos
      end
    end
  end
end
