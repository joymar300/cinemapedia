import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/screens/providers/movies/movies_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moviesSlideShowProvider = Provider<List<Movie>>((ref) {
  final nowplayingMovies = ref.watch(nowPlayingMoviesProvider);
  if (nowplayingMovies.isEmpty) return [];
  return nowplayingMovies.sublist(0, 6);
});
