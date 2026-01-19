require 'rails_helper'

RSpec.describe "Weather Page" do
  before :each do
    # stub the weather api request to return a valid response
    @weather_api_stub = stub_request(:get, "http://api.weatherapi.com/v1/forecast.json").
                          with(query: hash_including({})).
                          to_return(status: 200, body: File.read("spec/fixtures/weather_api_200.json"))

    # stub the API Key load to resolve without error
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("WEATHER_API_KEY").and_return("test_api_key")
  end

  it "renders an input for the location" do
    visit "/"

    expect(page).to have_field("location")
  end

  it "renders the forecast when location is entered" do
    visit "/"

    expect(page).to have_field("location")

    fill_in :location, with: "London"

    click_button "Submit"

    within "#current" do
      expect(page).to have_content("Today's Weather")
      expect(page).to have_content("Current Temperature: 50°F")
      expect(page).to have_content("High: 50°F")
      expect(page).to have_content("Low: 41°F")
    end

    within "#day-1" do
      expect(page).to have_content("Tuesday")
      expect(page).to have_content("Patchy rain nearby")
      expect(page).to have_content("High: 51°F")
      expect(page).to have_content("Low: 41°F")
    end
  end
end