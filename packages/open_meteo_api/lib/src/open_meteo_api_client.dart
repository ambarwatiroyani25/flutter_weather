import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/location.dart';
import 'models/weather.dart';

class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Location> locationSearch(String query) async {
    final request = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': query,
        'count': '1',
      },
    );

    final response = await _httpClient.get(request);

    if (response.statusCode != 200) {
      throw LocationRequestFailure();
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (!body.containsKey('results')) {
      throw LocationNotFoundFailure();
    }

    final results = body['results'] as List;

    if (results.isEmpty) {
      throw LocationNotFoundFailure();
    }

    return Location.fromJson(
      results.first as Map<String, dynamic>,
    );
  }

  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final request = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current_weather': 'true',
      },
    );

    final response = await _httpClient.get(request);

    if (response.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (!body.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    return Weather.fromJson(
      body['current_weather'] as Map<String, dynamic>,
    );
  }

  void close() {
    _httpClient.close();
  }
}

class LocationRequestFailure implements Exception {}

class LocationNotFoundFailure implements Exception {}

class WeatherRequestFailure implements Exception {}

class WeatherNotFoundFailure implements Exception {}