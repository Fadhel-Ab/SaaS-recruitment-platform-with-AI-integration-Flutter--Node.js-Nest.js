import 'package:frontend/features/search/data/search_api.dart';
import 'package:frontend/features/search/model/search_results.dart';

class SearchRepository {
  final SearchApi api;

  SearchRepository(this.api);

  Future<SearchResults> search(String query) async {
    final data = await api.search(query);
    return SearchResults.fromJson(data);
  }
}
