class WeatherController < ApplicationController
  def index
    if params[:location].present?
      zip = extract_zip(params[:location])
      @cached = true
      @forecast = Rails.cache.fetch(zip, expires_in: 30.minutes) do
        @cached = false
        WeatherApiService.get_weather(zip)
      end
    end
  rescue WeatherApiService::Error => error
    @error = error
  end

  def extract_zip(address)
    # Find the zip code by regex
    # Match a single token that is either five digits
    # Or five digits hyphenated with four digits
    address[/\b\d{5}(?:-\d{4})?\b/]
  end
end