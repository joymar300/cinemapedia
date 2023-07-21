import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie_screen';
  final String movieId;
  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(movieinfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActor(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieinfoProvider)[widget.movieId];
    if (movie == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          strokeWidth: 2,
        )),
      );
    }
    return Scaffold(
        body: CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        _CustomSliverAppBar(movie: movie),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) => _Moviedetails(movie: movie),
          childCount: 1,
        ))
      ],
    ));
  }
}

class _Moviedetails extends StatelessWidget {
  final Movie movie;
  const _Moviedetails({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),
              const SizedBox(width: 10),
              //* descripción
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: textStyle.titleLarge),
                      Text(movie.overview)
                    ]),
              )
            ],
          ),
        ),
        //* generos de la pelicula
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(gender),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ))
            ],
          ),
        ),

        _ActorsByMovie(movieId: movie.id.toString()),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;
  const _ActorsByMovie({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);
    if (actorsByMovie[movieId] == null) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }
    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Container(
            padding: const EdgeInsets.all(0.8),
            width: 135,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  actor.profilePath!,
                  height: 180,
                  width: 135,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress != null) return const SizedBox();
                    return FadeIn(child: child);
                  },
                ),
              ),
              const SizedBox(height: 5),
              Text(actor.name, maxLines: 2),
              Text(
                actor.character ?? '',
                maxLines: 2,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
              )
            ]),
          );
        },
      ),
    );
  }
}

final isFavoriteProvider = FutureProvider.family((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);

  return localStorageRepository.isMovieFavorite(movieId);
});

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;
  const _CustomSliverAppBar({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isfavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: () async {
            // ref.watch(localStorageRepositoryProvider).toggleFavorite(movie);
            // ref.invalidate(isFavoriteProvider(movie.id));
            await ref
                .read(favoriteMoviesProvider.notifier)
                .toggleFavorite(movie);
            ref.invalidate(isFavoriteProvider(movie.id));
          },
          icon: isfavoriteFuture.when(
              data: (data) => data
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite_border),
              error: (_, __) => throw UnimplementedError(),
              loading: () => const CircularProgressIndicator(strokeWidth: 2)),

          //icon: Icon(Icons.favorite, color: Colors.red),
        )
      ],
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),
            const _CustomGaradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1.0],
                colors: [Colors.transparent, Colors.black87]),
            // const SizedBox.expand(
            //   child: DecoratedBox(
            //       decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //               begin: Alignment.topCenter,
            //               end: Alignment.bottomCenter,
            //               stops: [0.7, 1.0],
            //               colors: [Colors.transparent, Colors.black87]))),
            // ),

            const _CustomGaradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomLeft,
                stops: [0, 0, 0.4],
                colors: [Colors.black87, Colors.transparent]),
            // const SizedBox.expand(
            //   child: DecoratedBox(
            //       decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //               begin: Alignment.topRight,
            //               end: Alignment.bottomLeft,
            //               stops: [0.0, 0.4],
            //               colors: [Colors.black87, Colors.transparent]))),
            // ),
            const _CustomGaradient(
                begin: Alignment.topLeft,
                stops: [0.0, 0.4],
                colors: [Colors.black87, Colors.transparent]),
            // const SizedBox.expand(
            //   child: DecoratedBox(
            //       decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //               begin: Alignment.topLeft,
            //               stops: [0.0, 0.4],
            //               colors: [Colors.black87, Colors.transparent]))),
            // )
          ],
        ),
      ),
    );
  }
}

class _CustomGaradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGaradient({
    required this.begin,
    required this.stops,
    required this.colors,
    this.end = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, stops: stops, colors: colors))),
    );
  }
}
