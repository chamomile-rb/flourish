# frozen_string_literal: true

module Flourish
  class Style # rubocop:disable Metrics/ClassLength
    # Property symbols
    BOLD = :bold
    ITALIC = :italic
    FAINT = :faint
    BLINK = :blink
    STRIKETHROUGH = :strikethrough
    UNDERLINE = :underline
    REVERSE = :reverse
    FOREGROUND = :foreground
    BACKGROUND = :background
    TAB_WIDTH = :tab_width
    INLINE = :inline
    TRANSFORM = :transform
    WIDTH = :width
    HEIGHT = :height
    MAX_WIDTH = :max_width
    MAX_HEIGHT = :max_height
    PADDING_TOP = :padding_top
    PADDING_RIGHT = :padding_right
    PADDING_BOTTOM = :padding_bottom
    PADDING_LEFT = :padding_left
    MARGIN_TOP = :margin_top
    MARGIN_RIGHT = :margin_right
    MARGIN_BOTTOM = :margin_bottom
    MARGIN_LEFT = :margin_left
    BORDER_STYLE = :border_style
    BORDER_TOP = :border_top
    BORDER_RIGHT = :border_right
    BORDER_BOTTOM = :border_bottom
    BORDER_LEFT = :border_left
    BORDER_TOP_FG = :border_top_fg
    BORDER_RIGHT_FG = :border_right_fg
    BORDER_BOTTOM_FG = :border_bottom_fg
    BORDER_LEFT_FG = :border_left_fg
    BORDER_TOP_BG = :border_top_bg
    BORDER_RIGHT_BG = :border_right_bg
    BORDER_BOTTOM_BG = :border_bottom_bg
    BORDER_LEFT_BG = :border_left_bg
    ALIGN_HORIZONTAL = :align_horizontal
    ALIGN_VERTICAL = :align_vertical
    UNDERLINE_SPACES = :underline_spaces
    STRIKETHROUGH_SPACES = :strikethrough_spaces
    COLOR_WHITESPACE = :color_whitespace

    SGR_CODES = {
      BOLD => "1",
      FAINT => "2",
      ITALIC => "3",
      UNDERLINE => "4",
      BLINK => "5",
      REVERSE => "7",
      STRIKETHROUGH => "9",
    }.freeze

    DEFAULT_TAB_WIDTH = 4

    def initialize
      @props = {}
      @set_props = Set.new
    end

    # --- Text attributes ---

    def bold(v = true)
      set_prop(BOLD, v)
    end

    def italic(v = true)
      set_prop(ITALIC, v)
    end

    def faint(v = true)
      set_prop(FAINT, v)
    end

    def blink(v = true)
      set_prop(BLINK, v)
    end

    def strikethrough(v = true)
      set_prop(STRIKETHROUGH, v)
    end

    def underline(v = true)
      set_prop(UNDERLINE, v)
    end

    def reverse(v = true)
      set_prop(REVERSE, v)
    end

    # --- Colors ---

    def foreground(color)
      set_prop(FOREGROUND, Color.parse(color))
    end

    def background(color)
      set_prop(BACKGROUND, Color.parse(color))
    end

    # --- Utility ---

    def tab_width(n)
      set_prop(TAB_WIDTH, n)
    end

    def inline(v = true)
      set_prop(INLINE, v)
    end

    def transform(&block)
      set_prop(TRANSFORM, block)
    end

    # --- Dimensions ---

    def width(n)
      set_prop(WIDTH, n)
    end

    def height(n)
      set_prop(HEIGHT, n)
    end

    def max_width(n)
      set_prop(MAX_WIDTH, n)
    end

    def max_height(n)
      set_prop(MAX_HEIGHT, n)
    end

    # --- Padding (CSS shorthand) ---

    def padding(*args)
      case args.length
      when 1
        set_prop(PADDING_TOP, args[0])
        set_prop(PADDING_RIGHT, args[0])
        set_prop(PADDING_BOTTOM, args[0])
        set_prop(PADDING_LEFT, args[0])
      when 2
        set_prop(PADDING_TOP, args[0])
        set_prop(PADDING_BOTTOM, args[0])
        set_prop(PADDING_RIGHT, args[1])
        set_prop(PADDING_LEFT, args[1])
      when 3
        set_prop(PADDING_TOP, args[0])
        set_prop(PADDING_RIGHT, args[1])
        set_prop(PADDING_BOTTOM, args[2])
        set_prop(PADDING_LEFT, args[1])
      when 4
        set_prop(PADDING_TOP, args[0])
        set_prop(PADDING_RIGHT, args[1])
        set_prop(PADDING_BOTTOM, args[2])
        set_prop(PADDING_LEFT, args[3])
      end
      self
    end

    def padding_top(n) = set_prop(PADDING_TOP, n)
    def padding_right(n) = set_prop(PADDING_RIGHT, n)
    def padding_bottom(n) = set_prop(PADDING_BOTTOM, n)
    def padding_left(n) = set_prop(PADDING_LEFT, n)

    # --- Margin (CSS shorthand) ---

    def margin(*args)
      case args.length
      when 1
        set_prop(MARGIN_TOP, args[0])
        set_prop(MARGIN_RIGHT, args[0])
        set_prop(MARGIN_BOTTOM, args[0])
        set_prop(MARGIN_LEFT, args[0])
      when 2
        set_prop(MARGIN_TOP, args[0])
        set_prop(MARGIN_BOTTOM, args[0])
        set_prop(MARGIN_RIGHT, args[1])
        set_prop(MARGIN_LEFT, args[1])
      when 3
        set_prop(MARGIN_TOP, args[0])
        set_prop(MARGIN_RIGHT, args[1])
        set_prop(MARGIN_BOTTOM, args[2])
        set_prop(MARGIN_LEFT, args[1])
      when 4
        set_prop(MARGIN_TOP, args[0])
        set_prop(MARGIN_RIGHT, args[1])
        set_prop(MARGIN_BOTTOM, args[2])
        set_prop(MARGIN_LEFT, args[3])
      end
      self
    end

    def margin_top(n) = set_prop(MARGIN_TOP, n)
    def margin_right(n) = set_prop(MARGIN_RIGHT, n)
    def margin_bottom(n) = set_prop(MARGIN_BOTTOM, n)
    def margin_left(n) = set_prop(MARGIN_LEFT, n)

    # --- Border ---

    def border(style, *sides)
      set_prop(BORDER_STYLE, style)
      apply_border_sides(sides)
      self
    end

    def border_style(style)
      set_prop(BORDER_STYLE, style)
    end

    def border_top(v = true) = set_prop(BORDER_TOP, v)
    def border_right(v = true) = set_prop(BORDER_RIGHT, v)
    def border_bottom(v = true) = set_prop(BORDER_BOTTOM, v)
    def border_left(v = true) = set_prop(BORDER_LEFT, v)

    def border_foreground(*colors)
      apply_border_colors(colors, :fg)
      self
    end

    def border_background(*colors)
      apply_border_colors(colors, :bg)
      self
    end

    def border_top_foreground(color) = set_prop(BORDER_TOP_FG, Color.parse(color))
    def border_right_foreground(color) = set_prop(BORDER_RIGHT_FG, Color.parse(color))
    def border_bottom_foreground(color) = set_prop(BORDER_BOTTOM_FG, Color.parse(color))
    def border_left_foreground(color) = set_prop(BORDER_LEFT_FG, Color.parse(color))
    def border_top_background(color) = set_prop(BORDER_TOP_BG, Color.parse(color))
    def border_right_background(color) = set_prop(BORDER_RIGHT_BG, Color.parse(color))
    def border_bottom_background(color) = set_prop(BORDER_BOTTOM_BG, Color.parse(color))
    def border_left_background(color) = set_prop(BORDER_LEFT_BG, Color.parse(color))

    # --- Alignment ---

    def align(*positions)
      set_prop(ALIGN_HORIZONTAL, positions[0]) if positions.length >= 1
      set_prop(ALIGN_VERTICAL, positions[1]) if positions.length >= 2
      self
    end

    def align_horizontal(pos) = set_prop(ALIGN_HORIZONTAL, pos)
    def align_vertical(pos) = set_prop(ALIGN_VERTICAL, pos)

    # --- Whitespace options ---

    def underline_spaces(v = true) = set_prop(UNDERLINE_SPACES, v)
    def strikethrough_spaces(v = true) = set_prop(STRIKETHROUGH_SPACES, v)
    def color_whitespace(v = true) = set_prop(COLOR_WHITESPACE, v)

    # --- Getters ---

    # --- Public query methods ---

    def bold? = get_prop(BOLD, false)
    def italic? = get_prop(ITALIC, false)
    def faint? = get_prop(FAINT, false)
    def blink? = get_prop(BLINK, false)
    def strikethrough? = get_prop(STRIKETHROUGH, false)
    def underline? = get_prop(UNDERLINE, false)
    def reverse? = get_prop(REVERSE, false)
    def inline? = get_prop(INLINE, false)
    def foreground_color = get_prop(FOREGROUND, nil)
    def background_color = get_prop(BACKGROUND, nil)
    def border_top? = get_prop(BORDER_TOP, false)
    def border_right? = get_prop(BORDER_RIGHT, false)
    def border_bottom? = get_prop(BORDER_BOTTOM, false)
    def border_left? = get_prop(BORDER_LEFT, false)
    def underline_spaces? = get_prop(UNDERLINE_SPACES, false)
    def strikethrough_spaces? = get_prop(STRIKETHROUGH_SPACES, false)
    def color_whitespace? = get_prop(COLOR_WHITESPACE, false)

    # --- Inheritance ---

    def inherit(other)
      other.set_props.each do |prop|
        next if @set_props.include?(prop)

        @props[prop] = other.get_raw(prop)
        @set_props.add(prop)
      end
      self
    end

    def unset(*props)
      props.each do |prop|
        @set_props.delete(prop)
        @props.delete(prop)
      end
      self
    end

    def set?(prop)
      @set_props.include?(prop)
    end

    def copy
      new_style = Style.new
      @props.each { |k, v| new_style.instance_variable_get(:@props)[k] = v }
      @set_props.each { |p| new_style.instance_variable_get(:@set_props).add(p) }
      new_style
    end

    # --- Render ---

    def render(*strs)
      text = strs.join(" ")

      # Apply transform
      xform = get_prop(TRANSFORM, nil)
      text = xform.call(text) if xform

      # Convert tabs
      tw = get_tab_width
      text = text.gsub("\t", " " * tw) if tw.positive?

      # Calculate dimensions
      content_width = compute_content_width
      target_height = get_height

      # Word wrap if width is set
      text = Wrap.word_wrap(text, content_width) if content_width.positive?

      lines = text.split("\n", -1)
      lines = [""] if lines.empty?

      # Apply text SGR per line
      sgr = build_sgr
      lines = apply_sgr_to_lines(lines, sgr)

      # Alignment (inside border, after SGR)
      lines = apply_alignment(lines, content_width) if content_width.positive?

      # Enforce inner content height (before padding/border)
      if target_height.positive?
        inner_height = compute_inner_height(target_height)
        lines = enforce_height(lines, inner_height) if inner_height.positive?
      end

      # Padding
      lines = apply_padding(lines)

      # Border
      lines = apply_border(lines) if get_border_style

      # Margin
      lines = apply_margin(lines)

      # Enforce max constraints
      lines = enforce_max_width(lines)
      lines = enforce_max_height(lines)

      lines.join("\n")
    end

    protected

    # Accessible from other Style instances for inheritance
    attr_reader :set_props

    def get_raw(prop)
      @props[prop]
    end

    private

    # --- Internal getters ---

    def get_tab_width = get_prop(TAB_WIDTH, DEFAULT_TAB_WIDTH)
    def get_width = get_prop(WIDTH, 0)
    def get_height = get_prop(HEIGHT, 0)
    def get_max_width = get_prop(MAX_WIDTH, 0)
    def get_max_height = get_prop(MAX_HEIGHT, 0)
    def get_padding_top = get_prop(PADDING_TOP, 0)
    def get_padding_right = get_prop(PADDING_RIGHT, 0)
    def get_padding_bottom = get_prop(PADDING_BOTTOM, 0)
    def get_padding_left = get_prop(PADDING_LEFT, 0)
    def get_margin_top = get_prop(MARGIN_TOP, 0)
    def get_margin_right = get_prop(MARGIN_RIGHT, 0)
    def get_margin_bottom = get_prop(MARGIN_BOTTOM, 0)
    def get_margin_left = get_prop(MARGIN_LEFT, 0)
    def get_border_style = get_prop(BORDER_STYLE, nil)
    def get_align_horizontal = get_prop(ALIGN_HORIZONTAL, Flourish::LEFT)
    def get_align_vertical = get_prop(ALIGN_VERTICAL, Flourish::TOP)

    def set_prop(prop, value)
      @props[prop] = value
      @set_props.add(prop)
      self
    end

    def get_prop(prop, default)
      return default unless @set_props.include?(prop)

      @props.fetch(prop, default)
    end

    def compute_content_width
      w = get_width
      return 0 if w <= 0

      w -= get_padding_left + get_padding_right
      w -= 1 if border_left?
      w -= 1 if border_right?
      [w, 0].max
    end

    def compute_inner_height(total_height)
      h = total_height
      h -= get_padding_top + get_padding_bottom
      h -= 1 if border_top?
      h -= 1 if border_bottom?
      [h, 0].max
    end

    def build_sgr
      parts = []

      SGR_CODES.each do |attr, code|
        parts << code if get_prop(attr, false)
      end

      fg = get_prop(FOREGROUND, nil)
      parts << fg.fg_sequence if fg && !fg.no_color?

      bg = get_prop(BACKGROUND, nil)
      parts << bg.bg_sequence if bg && !bg.no_color?

      parts.join(";")
    end

    def apply_sgr_to_lines(lines, sgr)
      return lines if sgr.empty?

      lines.map do |line|
        "\e[#{sgr}m#{line}\e[0m"
      end
    end

    def apply_alignment(lines, content_width)
      h_pos = get_align_horizontal
      Align.horizontal(lines, content_width, h_pos)
    end

    def apply_padding(lines)
      pt = get_padding_top
      pr = get_padding_right
      pb = get_padding_bottom
      pl = get_padding_left

      return lines if pt.zero? && pr.zero? && pb.zero? && pl.zero?

      left_fill = Whitespace.fill(pl)
      right_fill = Whitespace.fill(pr)

      ws_sgr = build_whitespace_sgr
      unless ws_sgr.empty?
        left_fill = "\e[#{ws_sgr}m#{left_fill}\e[0m" unless left_fill.empty?
        right_fill = "\e[#{ws_sgr}m#{right_fill}\e[0m" unless right_fill.empty?
      end

      result = []
      blank_line = build_blank_padding_line(left_fill, right_fill, lines)
      pt.times { result << blank_line }
      lines.each { |line| result << "#{left_fill}#{line}#{right_fill}" }
      pb.times { result << blank_line }
      result
    end

    def build_blank_padding_line(left_fill, right_fill, lines)
      # Calculate the inner content width from existing lines
      inner_width = lines.map { |l| ANSI.printable_width(l) }.max || 0
      inner_fill = Whitespace.fill(inner_width)
      ws_sgr = build_whitespace_sgr
      inner_fill = "\e[#{ws_sgr}m#{inner_fill}\e[0m" if !ws_sgr.empty? && !inner_fill.empty?
      "#{left_fill}#{inner_fill}#{right_fill}"
    end

    def build_whitespace_sgr
      return "" unless color_whitespace?

      parts = []
      bg = get_prop(BACKGROUND, nil)
      parts << bg.bg_sequence if bg && !bg.no_color?
      parts.join(";")
    end

    def apply_border(lines)
      bs = get_border_style
      return lines unless bs

      has_top = border_top?
      has_bottom = border_bottom?
      has_left = border_left?
      has_right = border_right?

      return lines unless has_top || has_bottom || has_left || has_right

      content_width = lines.map { |l| ANSI.printable_width(l) }.max || 0

      result = []

      if has_top
        top_line = build_border_top(bs, content_width, has_left, has_right)
        result << top_line
      end

      lines.each do |line|
        bordered = +""
        bordered << style_border_char(bs.left, :left) if has_left
        line_width = ANSI.printable_width(line)
        pad = content_width - line_width
        bordered << line
        bordered << (" " * pad) if pad.positive?
        bordered << style_border_char(bs.right, :right) if has_right
        result << bordered
      end

      if has_bottom
        bottom_line = build_border_bottom(bs, content_width, has_left, has_right)
        result << bottom_line
      end

      result
    end

    def build_border_top(bs, width, has_left, has_right)
      line = +""
      line << style_border_char(bs.top_left, :top) if has_left
      line << style_border_char(bs.top * width, :top)
      line << style_border_char(bs.top_right, :top) if has_right
      line
    end

    def build_border_bottom(bs, width, has_left, has_right)
      line = +""
      line << style_border_char(bs.bottom_left, :bottom) if has_left
      line << style_border_char(bs.bottom * width, :bottom)
      line << style_border_char(bs.bottom_right, :bottom) if has_right
      line
    end

    def style_border_char(char, side)
      fg_prop = :"border_#{side}_fg"
      bg_prop = :"border_#{side}_bg"
      fg = get_prop(fg_prop, nil)
      bg = get_prop(bg_prop, nil)

      parts = []
      parts << fg.fg_sequence if fg && !fg.no_color?
      parts << bg.bg_sequence if bg && !bg.no_color?

      return char if parts.empty?

      "\e[#{parts.join(";")}m#{char}\e[0m"
    end

    def enforce_height(lines, target_height)
      if lines.length < target_height
        v_pos = get_align_vertical
        Align.vertical(lines, target_height, v_pos)
      elsif lines.length > target_height
        lines[0, target_height]
      else
        lines
      end
    end

    def apply_margin(lines)
      mt = get_margin_top
      mr = get_margin_right
      mb = get_margin_bottom
      ml = get_margin_left

      return lines if mt.zero? && mr.zero? && mb.zero? && ml.zero?

      left_fill = Whitespace.fill(ml)
      right_fill = Whitespace.fill(mr)

      result = []
      mt.times { result << "" }
      lines.each { |line| result << "#{left_fill}#{line}#{right_fill}" }
      mb.times { result << "" }
      result
    end

    def enforce_max_width(lines)
      mw = get_max_width
      return lines if mw <= 0

      lines.map do |line|
        truncate_line(line, mw)
      end
    end

    def enforce_max_height(lines)
      mh = get_max_height
      return lines if mh <= 0
      return lines if lines.length <= mh

      lines[0, mh]
    end

    def truncate_line(line, max_width)
      width = 0
      result = +""
      i = 0
      chars = line.chars
      has_open_sgr = false

      while i < chars.length
        seq = chars[i] == "\e" ? extract_escape_at(chars, i) : nil
        if seq
          result << seq
          has_open_sgr = sgr_open_after?(has_open_sgr, seq)
          i += seq.length
          next
        end

        ch_w = ANSI.printable_width(chars[i])
        break if width + ch_w > max_width

        result << chars[i]
        width += ch_w
        i += 1
      end

      # Close any open SGR sequences to prevent escape code leaking
      result << "\e[0m" if has_open_sgr

      result
    end

    def extract_escape_at(chars, start)
      return nil unless chars[start] == "\e"

      i = start + 1
      return nil if i >= chars.length

      if chars[i] == "["
        seq = +"\e["
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

    def sgr_open_after?(was_open, seq)
      return false if ["\e[0m", "\e[m"].include?(seq)
      return true if seq.match?(/\A\e\[\d/)

      was_open
    end

    def apply_border_sides(sides)
      case sides.length
      when 0
        set_prop(BORDER_TOP, true)
        set_prop(BORDER_RIGHT, true)
        set_prop(BORDER_BOTTOM, true)
        set_prop(BORDER_LEFT, true)
      when 1
        set_prop(BORDER_TOP, sides[0])
        set_prop(BORDER_RIGHT, sides[0])
        set_prop(BORDER_BOTTOM, sides[0])
        set_prop(BORDER_LEFT, sides[0])
      when 2
        set_prop(BORDER_TOP, sides[0])
        set_prop(BORDER_BOTTOM, sides[0])
        set_prop(BORDER_RIGHT, sides[1])
        set_prop(BORDER_LEFT, sides[1])
      when 3
        set_prop(BORDER_TOP, sides[0])
        set_prop(BORDER_RIGHT, sides[1])
        set_prop(BORDER_BOTTOM, sides[2])
        set_prop(BORDER_LEFT, sides[1])
      when 4
        set_prop(BORDER_TOP, sides[0])
        set_prop(BORDER_RIGHT, sides[1])
        set_prop(BORDER_BOTTOM, sides[2])
        set_prop(BORDER_LEFT, sides[3])
      end
    end

    def apply_border_colors(colors, type)
      suffix = type == :fg ? "_fg" : "_bg"
      props = [:"border_top#{suffix}", :"border_right#{suffix}",
               :"border_bottom#{suffix}", :"border_left#{suffix}",]

      parsed = colors.map { |c| Color.parse(c) }

      case parsed.length
      when 1
        props.each { |p| set_prop(p, parsed[0]) }
      when 2
        set_prop(props[0], parsed[0])
        set_prop(props[2], parsed[0])
        set_prop(props[1], parsed[1])
        set_prop(props[3], parsed[1])
      when 3
        set_prop(props[0], parsed[0])
        set_prop(props[1], parsed[1])
        set_prop(props[2], parsed[2])
        set_prop(props[3], parsed[1])
      when 4
        props.each_with_index { |p, i| set_prop(p, parsed[i]) }
      end
    end
  end
end
