require 'rails_helper'

RSpec.describe WeatherApiService do
  context "Weather API response is 200" do
    before :each do
      # stub the weather api request to return a valid response
      @weather_api_stub = stub_request(:get, "http://api.weatherapi.com/v1/forecast.json").
                            with(query: hash_including({})).
                            to_return(status: 200, body: File.read("spec/fixtures/weather_api_200.json"))

      # stub the API Key load to resolve without error
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("WEATHER_API_KEY").and_return("test_api_key")
    end

    it 'makes a call to the weather api' do
      WeatherApiService.get_weather("London")

      expect(@weather_api_stub).to have_been_requested.times(1)
    end

    it 'returns the current temp, high, low, and three day forecast' do
      response = WeatherApiService.get_weather("London")

      expect(response[:current][:temp_c]).to eq(10.1)
      expect(response[:current][:temp_f]).to eq(50.2)
      expect(response[:forecast][:forecastday][0][:day][:maxtemp_c]).to eq(10.1)
      expect(response[:forecast][:forecastday][0][:day][:maxtemp_f]).to eq(50.2)
      expect(response[:forecast][:forecastday][0][:day][:mintemp_c]).to eq(5.2)
      expect(response[:forecast][:forecastday][0][:day][:mintemp_f]).to eq(41.4)
      expect(response[:forecast][:forecastday][0][:day][:condition][:text]).to eq("Patchy rain nearby")
      expect(response[:forecast][:forecastday][0][:day][:condition][:icon]).to eq("//cdn.weatherapi.com/weather/64x64/day/176.png")
    end
  end

  context "Weather API response returns an error" do
    it 'raises the error with the given error message' do
      # stub the weather api request to return a 400 response
      body = "invalid api key"
      @weather_api_stub = stub_request(:get, "http://api.weatherapi.com/v1/forecast.json").
                            with(query: hash_including({})).
                            to_return(status: 400, body: File.read("spec/fixtures/weather_api_400.json"))

      # stub the API Key load to resolve without error
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("WEATHER_API_KEY").and_return("test_api_key")

      expect {
        WeatherApiService.get_weather("****")
      }.to raise_error(WeatherApiService::Error, "No matching location found.")
    end
  end

  context "Weather API response fails without a properly formatted error" do
    it 'raises an error with the response body contents' do
      # stub the weather api request to return a 403 response
      # sometimes this API does not return an error in the expected format
      # this test ensures that case is handled
      @weather_api_stub = stub_request(:get, "http://api.weatherapi.com/v1/forecast.json").
                            with(query: hash_including({})).
                            to_return(status: 403, body: "403")

      # stub the API Key load to resolve without error
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("WEATHER_API_KEY").and_return("test_api_key")

      expect {
        WeatherApiService.get_weather("London")
      }.to raise_error(WeatherApiService::Error, "403")
    end
  end

  context "API Key is not loaded" do
    it "raises an error" do
      expect {
        WeatherApiService.get_weather("London")
      }.to raise_error(WeatherApiService::Error, "WEATHER_API_KEY loading failed")
    end
  end
end