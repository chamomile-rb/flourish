#!/usr/bin/env ruby
# frozen_string_literal: true

# Interactive Layout Demo — Lazygit-style multi-panel UI
#
# Demonstrates Flourish's layout capabilities (join, borders, alignment)
# combined with Chamomile's event loop and keyboard navigation.
#
# Usage: ruby examples/layout_demo_interactive.rb

$LOAD_PATH.unshift File.expand_path("../../chamomile/lib", __dir__)
$LOAD_PATH.unshift File.expand_path("../../petals/lib", __dir__)
require_relative "../lib/flourish"
require "chamomile"

class LayoutDemo
  include Chamomile::Application

  PANELS = %i[status files branches commits stash main].freeze

  PANEL_TITLES = {
    status: "Status",
    files: "Files",
    branches: "Branches",
    commits: "Commits",
    stash: "Stash",
    main: "Main",
  }.freeze

  PANEL_DATA = {
    status: ["On branch: main", "Up to date with origin/main", "", "nothing to commit"],
    files: ["M lib/flourish/style.rb", "M lib/flourish/wrap.rb", "A examples/kitchen_sink.rb",
            "M spec/flourish/style_spec.rb", "? tmp/debug.log",],
    branches: ["* main", "  feature/layout", "  feature/colors", "  fix/border-bug", "  dev"],
    commits: ["abc1234 Fix border rendering bug", "def5678 Add ANSI-aware word wrap",
              "789abcd Refactor style pipeline", "012efab Add color downsampling",
              "345cdef Initial Flourish commit",],
    stash: ["stash@{0}: WIP on main: half-done refactor"],
  }.freeze

  FOCUSED_COLOR   = "#7d56f4"
  UNFOCUSED_COLOR = "#444444"
  GREEN           = "#04b575"
  RED             = "#ff6347"
  DIM             = "#666666"

  LEFT_PANELS = %i[status files branches commits stash].freeze

  def initialize
    @focused = 1 # start on :files
    @width   = 80
    @height  = 24
    @cursor  = Hash.new(0)
  end

  def update(msg)
    case msg
    when Chamomile::ResizeEvent
      @width  = msg.width
      @height = msg.height

    when Chamomile::KeyEvent
      case msg.key
      when "q"
        return quit
      when :tab
        @focused = if msg.shift?
                     (@focused - 1) % PANELS.size
                   else
                     (@focused + 1) % PANELS.size
                   end
      when "j", :down
        panel = PANELS[@focused]
        items = PANEL_DATA[panel]
        @cursor[panel] = [(@cursor[panel] + 1), items.size - 1].min if items
      when "k", :up
        panel = PANELS[@focused]
        @cursor[panel] = [(@cursor[panel] - 1), 0].max if PANEL_DATA[panel]
      end
    end
    nil
  end

  def view
    left_w  = [@width * 3 / 10, 20].max
    right_w = @width - left_w
    # Reserve 1 line for status bar
    body_h  = @height - 1

    # Render left panels, splitting height evenly
    left_panels = render_left_column(left_w, body_h)
    right_panel = render_panel(:main, right_w, body_h)

    layout = Flourish.horizontal([left_panels, right_panel], align: :top)
    bar    = status_bar(@width)

    Flourish.vertical([layout, bar], align: :left)
  end

  private

  def render_left_column(col_width, total_h)
    count = LEFT_PANELS.size
    # Distribute height: each panel gets base_h, remainder goes to first panels
    inner_heights = distribute_heights(total_h, count)

    panels = LEFT_PANELS.each_with_index.map do |key, i|
      render_panel(key, col_width, inner_heights[i])
    end

    Flourish.vertical(panels, align: :left)
  end

  def distribute_heights(total, count)
    # .height(h) sets total rendered height (borders included),
    # so distribute total directly among panels
    base = total / count
    extra = total % count
    Array.new(count) { |i| i < extra ? base + 1 : base }
  end

  def render_panel(key, panel_width, panel_height)
    focused = PANELS[@focused] == key
    color   = focused ? FOCUSED_COLOR : UNFOCUSED_COLOR

    if key == :main
      content = render_detail(panel_width - 2, panel_height - 2)
    else
      items   = PANEL_DATA[key] || []
      cursor  = @cursor[key]
      inner_w = panel_width - 2 # border takes 2 columns

      lines = items.each_with_index.map do |item, i|
        text = truncate(item, inner_w)
        if focused && i == cursor
          "\e[7m#{pad_right(text, inner_w)}\e[0m"
        else
          text
        end
      end
      content = lines.join("\n")
    end

    rendered = Flourish::Style.new
                              .border(Flourish::Border::ROUNDED)
                              .border_foreground(color)
                              .width(panel_width)
                              .height(panel_height)
                              .render(content)

    inject_title(rendered, PANEL_TITLES[key], focused ? FOCUSED_COLOR : DIM)
  end

  def render_detail(detail_width, detail_height)
    panel = PANELS[@focused]
    items = PANEL_DATA[panel]

    header_text, body_lines = if items.nil?
                                ["Main Panel", ["Select an item from a left panel", "to see details here."]]
                              else
                                detail_for(panel, @cursor[panel], detail_width)
                              end

    header = "\e[1m\e[38;2;4;181;117m#{header_text}\e[0m"
    lines  = [header, ""] + body_lines
    lines.map { |l| truncate(l, detail_width) }.take([detail_height, lines.size].min).join("\n")
  end

  def detail_for(panel, cursor, _detail_width)
    items = PANEL_DATA[panel]
    item  = items[cursor] || items[0]

    case panel
    when :status
      ["Status Detail", [item, "", "Working tree clean.", "Use 'git status' for more info."]]
    when :files
      file = item.sub(/^[MAD?]\s+/, "")
      status_char = item[0]
      status_word = { "M" => "modified", "A" => "added", "?" => "untracked" }[status_char] || "unknown"
      header = "#{file} (#{status_word})"
      diff = fake_diff(file)
      [header, diff]
    when :branches
      branch = item.sub(/^\*?\s+/, "")
      ["Branch: #{branch}", [
        "Last commit: abc1234",
        "Author: dev@example.com",
        "Date:   2 days ago",
        "",
        "Tracking: origin/#{branch}",
        branch == "main" ? "Status: up to date" : "Status: 3 commits ahead",
      ],]
    when :commits
      sha  = item[0, 7]
      desc = item[8..]
      ["Commit #{sha}", [
        "Author: dev@example.com",
        "Date:   3 days ago",
        "",
        "    #{desc}",
        "",
        *fake_diff_stats,
      ],]
    when :stash
      ["Stash Details", [
        item,
        "",
        "Created: 1 hour ago",
        "Branch: main",
        "",
        *fake_diff_stats,
      ],]
    else
      [item.to_s, []]
    end
  end

  def fake_diff(file)
    green = "\e[38;2;4;181;117m"
    red   = "\e[38;2;255;99;71m"
    reset = "\e[0m"

    [
      "#{red}--- a/#{file}#{reset}",
      "#{green}+++ b/#{file}#{reset}",
      "@@ -10,6 +10,8 @@",
      " ",
      " def render(content)",
      "#{red}-  lines = content.split(\"\\n\")#{reset}",
      "#{green}+  lines = content.split(\"\\n\", -1)#{reset}",
      "#{green}+  lines.reject!(&:empty?) if @strip#{reset}",
      " ",
      "   lines.map do |line|",
      "     apply_style(line)",
      "   end",
    ]
  end

  def fake_diff_stats
    green = "\e[38;2;4;181;117m"
    red   = "\e[38;2;255;99;71m"
    reset = "\e[0m"

    [
      "#{green}+12#{reset} #{red}-4#{reset} lib/flourish/style.rb",
      "#{green} +3#{reset} #{red}-1#{reset} lib/flourish/wrap.rb",
      "",
      "2 files changed, 15 insertions(+), 5 deletions(-)",
    ]
  end

  def inject_title(rendered, title, color)
    lines = rendered.split("\n")
    return rendered if lines.empty?

    title_str = " #{title} "
    r, g, b = hex_to_rgb(color)
    styled = "\e[1m\e[38;2;#{r};#{g};#{b}m#{title_str}\e[0m"

    top = lines[0]
    stripped = Flourish::ANSI.strip(top)
    lines[0] = splice_title_into_border(top, stripped, title_str, styled) if stripped.length >= title_str.length + 3

    lines.join("\n")
  end

  def splice_title_into_border(top, _stripped, title_str, styled)
    # Replace visible chars 2..(2+title_len-1) with the styled title
    visible_idx = 0
    byte_start = nil
    byte_end = nil
    i = 0
    while i < top.length
      if top[i] == "\e"
        j = i + 1
        j += 1 while j < top.length && top[j] != "m"
        i = j + 1
      else
        byte_start = i if visible_idx == 2
        if visible_idx == 2 + title_str.length
          byte_end = i
          break
        end
        visible_idx += 1
        i += top[i].valid_encoding? ? top[i].length : 1
      end
    end

    if byte_start && byte_end
      top[0...byte_start] + styled + top[byte_end..]
    elsif byte_start
      top[0...byte_start] + styled
    else
      top
    end
  end

  def hex_to_rgb(hex)
    hex = hex.delete("#")
    hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3
    [hex[0, 2].to_i(16), hex[2, 2].to_i(16), hex[4, 2].to_i(16)]
  end

  def status_bar(bar_width)
    Flourish::Style.new
                   .foreground(DIM)
                   .width(bar_width)
                   .render(" Tab/Shift+Tab navigate \u2502 j/k scroll \u2502 q quit")
  end

  def truncate(str, max_w)
    return str if max_w <= 0

    visible = 0
    i = 0
    while i < str.length
      if str[i] == "\e"
        j = i + 1
        j += 1 while j < str.length && str[j] != "m"
        i = j + 1
      else
        visible += 1
        return str[0...i] if visible > max_w

        i += 1
      end
    end
    str
  end

  def pad_right(str, target_width)
    visible_len = Flourish::ANSI.printable_width(str)
    if visible_len < target_width
      str + (" " * (target_width - visible_len))
    else
      str
    end
  end
end

Chamomile.run(LayoutDemo.new, alt_screen: true)
