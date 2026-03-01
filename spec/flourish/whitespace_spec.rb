# frozen_string_literal: true

RSpec.describe Flourish::Whitespace do
  describe ".fill" do
    it "returns spaces of given width" do
      expect(described_class.fill(5)).to eq("     ")
    end

    it "returns empty string for width 0" do
      expect(described_class.fill(0)).to eq("")
    end

    it "returns empty string for negative width" do
      expect(described_class.fill(-1)).to eq("")
    end

    it "uses custom fill character" do
      expect(described_class.fill(3, ".")).to eq("...")
    end

    it "returns single space for width 1" do
      expect(described_class.fill(1)).to eq(" ")
    end
  end
end
