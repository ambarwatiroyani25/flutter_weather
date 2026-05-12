import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_repository/weather_repository.dart' show WeatherRepository;

class WeatherApp extends StatelessWidget {
  // Sebaiknya inject repository lewat constructor agar lebih clean
  const WeatherApp({super.key, required WeatherRepository weatherRepository}) 
      : _weatherRepository = weatherRepository;

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: BlocProvider(
        // Menggunakan context.read dari RepositoryProvider di atasnya
        create: (context) => WeatherCubit(context.read<WeatherRepository>()),
        child: const WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  const WeatherAppView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan seleksi yang lebih aman jika state awal weather bisa null
    final seedColor = context.select(
      (WeatherCubit cubit) => cubit.state.weather.toColor,
    );

    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        textTheme: GoogleFonts.rajdhaniTextTheme(),
      ),
      home: const WeatherPage(),
    );
  }
}

extension on Weather {
  Color get toColor {
    // Pastikan enum WeatherCondition di bawah ini sesuai dengan 
    // definisi yang ada di package weather_repository kamu
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.yellow;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
      default: // Tambahkan default agar tidak error jika ada kondisi baru
        return Colors.cyan;
    }
  }
}