class WeatherController < ApplicationController
  def index
    if params[:location].present?
      @cached = true
      @forecast = Rails.cache.fetch(params[:location], expires_in: 30.minutes) do
        @cached = false
        WeatherApiService.get_weather(params[:location])
      end
    end
  rescue WeatherApiService::Error => error
    @error = error
  end
end