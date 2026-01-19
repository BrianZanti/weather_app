# Weather App

This application allows you to input an address to get the current weather and a three day forecast.

## Local Setup

If you would like to set up the app locally, first make sure you have Ruby 3.2.3 installed.

**Note:** If you do not have Ruby 3.2.3 installed or do not wish to install it, it is likely that this application code will work with different versions of Ruby 3.x. You can modify the gemfile's `ruby` setting if you would like to try a different version.

Then, run the following commands from the root directory:

```bash
  bundle install
  rails dev:cache
  rails s
```

In your web browser, visit `localhost:3000` to view the app.

## WeatherAPI

This application uses the [Weather API](https://www.weatherapi.com/) to retrieve forecast data.

If you would like to see real forecast data in this application, you will need to create an API key by signing up for free on the Weather API website.

Once you have your API key, install it by first creating a local file `.env`:

```bash
  touch .env
```

Then, create an Environment Variable called `WEATHER_API_KEY` and set it to your api key. You can find an example of how to format this in `.env.sample`.

You are also free to set up an Environment Variable in your local shell session using your preferred method.

## Caching

This application will cache weather data for 30 minutes. When a cache result is found an indicator message will appear at the top of the results screen.

When an address is used as the input, the zip code will be extracted from the text using a regex. This zip code is then used as the cache key so that subsequent requests for the same general area will not result in repeated API calls.

If an input does not contain a zip code, the input itself will be used as the cache key so that calls using the same input will not result in repeated API calls.

There are limitations to this approach, most notably when two different textual inputs that omit the zip code are located in the same zip, the second one would not be recognized as a cache hit. For example, the inputs `1701 Bryant St, Denver, CO` and `1605 Federal Blvd, Denver, CO` are both located in the zip code `80204`, but would not be seen as located in the same zip code by this application.

The way to solve this problem would be to use a Geocoding service, for example the [Google Geocoding API](https://developers.google.com/maps/documentation/geocoding/overview). If you call the geocoding service first, you would ensure that you can always map a text input to a zip code even if one is not given. This solution was not considered in-scope for this exercise.

Another notable design decision with caching is to perform it at the controller level. This approach has limitations if the application were to grow and have different code paths to performing the API calls. In that case, it would be best to create another layer of abstraction between the controller and API Service levels that can take responsibility for caching. This would ensure that the API Service itself is decoupled from caching and that caching is consistent across different controllers. However, this was not considered in-scope for this exercise.

## Tests

This code base includes an RSpec test suite. You can run the test suite locally with:

```
bundle exec rspec
```