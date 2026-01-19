class WeatherApiService
  class Error < StandardError
  end

  def self.get_weather(location)
    response = Faraday.get("http://api.weatherapi.com/v1/forecast.json", {
      key: ENV.fetch("WEATHER_API_KEY"),
      q: location,
      days: 4,
      aqi: 'no',
      alerts: 'no'
    })

    body = JSON.parse(response.body, symbolize_names: true)

    unless response.status == 200
      raise Error.new(body[:error][:message])
    end

    return body
  rescue KeyError
    raise Error.new("WEATHER_API_KEY loading failed")
  rescue TypeError
    raise Error.new(response.body)
  end
end