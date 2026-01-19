require 'rails_helper'

RSpec.describe "Weather Page" do

  it "renders an input for the location" do
    visit "/"

    expect(page).to have_content()
  end
end