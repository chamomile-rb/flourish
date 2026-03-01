# frozen_string_literal: true

require "flourish"

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
