import 'package:cinemapedia/presentation/screens/providers/actors/actors_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/actor.dart';

final actorsByMovieProvider =
    StateNotifierProvider<ActorsByMovieNotifier, Map<String, List<Actor>>>(
        (ref) {
  final actorRepository = ref.watch(actorRepositoryProvider);
  return ActorsByMovieNotifier(getActor: actorRepository.getActorsByMovie);
});

typedef GetActorsCallback = Future<List<Actor>> Function(String movieId);

class ActorsByMovieNotifier extends StateNotifier<Map<String, List<Actor>>> {
  final GetActorsCallback getActor;
  ActorsByMovieNotifier({required this.getActor}) : super({});
  Future<void> loadActor(String movieId) async {
    if (state[movieId] != null) return;

    final actor = await getActor(movieId);
    state = {...state, movieId: actor};
  }
}
