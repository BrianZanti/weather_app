class WeatherController < ApplicationController
  def index
    if params[:location].present?
      @forecast = WeatherApiService.get_weather(params[:location])
    end
  rescue WeatherApiService::Error => error
    @error = error
  end
end