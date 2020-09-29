import 'package:wikipedia_api/wikipedia_api.dart';
import 'package:meta/meta.dart';

/// Thrown when an error occurs while performing a search.
class SearchException implements Exception {}

class SearchRepository {
  SearchRepository({WikipediaApi wikipediaApiClient})
      : _wikipediaApiClient = wikipediaApiClient ?? WikipediaApi();

  final WikipediaApi _wikipediaApiClient;

  /// Returns a list of wiki pages for the provided [query].
  /// A [limit] can optionally be provided to control the number of search results.
  ///
  /// Throws a [SearchException] if an error occurs.
  Future<List<WikiPage>> search({@required String query, int limit}) async {
    assert(query != null && query.isNotEmpty);

    try {
      return await _wikipediaApiClient.searchPages(query, max: limit);
    } on Exception {
      throw SearchException();
    }
  }
}
