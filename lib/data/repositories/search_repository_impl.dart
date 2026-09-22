import '../../domain/entities/offense.dart';
import '../../domain/repositories/i_legal_repository.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../engine/search/search_engine.dart';
import '../datasources/seed_data_loader.dart';

class SearchRepositoryImpl implements ISearchRepository {
  final List<Offense> _offenses;
  late final SearchEngine _searchEngine;

  SearchRepositoryImpl([List<Offense>? offenses])
      : _offenses = offenses ?? SeedDataLoader.getSeedOffenses() {
    _searchEngine = SearchEngine(_offenses);
  }

  @override
  Future<List<Offense>> searchOffenses(String query, {DateTime? lookupDate}) async {
    final response = _searchEngine.search(query, lookupDate: lookupDate);
    return response.results.map((r) => r.offense).toList();
  }

  @override
  Future<SearchResponse> searchFull(String query, {DateTime? lookupDate}) async {
    return _searchEngine.search(query, lookupDate: lookupDate);
  }
}
