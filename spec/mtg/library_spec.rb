require "spec_helper"

RSpec.describe Mtg::Library do
  it "has a version number" do
    expect(Mtg::Library::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
