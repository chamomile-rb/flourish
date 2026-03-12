# frozen_string_literal: true

require_relative "../lib/flourish"

# Visual demo showing styled boxes composed together.

title_style = Flourish::Style.new
                             .bold
                             .foreground("#fafafa")
                             .background("#7d56f4")
                             .padding(0, 2)
                             .align_horizontal(:center)

info_style = Flourish::Style.new
                            .border(Flourish::Border::ROUNDED)
                            .border_foreground("#874bfa")
                            .padding(1, 2)
                            .width(40)

subtle_style = Flourish::Style.new
                              .foreground("8")

# Build boxes
title = title_style.render("Flourish — Terminal Styling for Ruby")

box1 = info_style.copy
                 .foreground("#ff7698")
                 .render("Colors\nTrue color, ANSI 256, and basic ANSI\nsupport with automatic downsampling.")

box2 = info_style.copy
                 .foreground("#04b575")
                 .render("Box Model\nCSS-like padding, margin, borders,\nand alignment for terminal output.")

footer = subtle_style.render("Part of the Chamomile ecosystem")

# Layout
boxes = Flourish.horizontal([box1, "  ", box2], align: :top)
output = Flourish.vertical([title, "", boxes, "", footer], align: :center)

puts output
