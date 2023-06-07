import 'package:flutter_dotenv/flutter_dotenv.dart';

class enviroment {
  static String theMovieDbKey =
      dotenv.env['THE_MOVIEDB_KEY'] ?? 'NO HAY API KEY';
}
