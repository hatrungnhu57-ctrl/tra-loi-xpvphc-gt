import '../entities/offense.dart';
import '../entities/provision.dart';
import '../entities/legal_document.dart';
import '../entities/case_evaluation.dart';
import '../entities/search_query_intent.dart';

abstract class ILegalRepository {
  Future<List<LegalDocument>> getAllDocuments();
  Future<List<Provision>> getProvisionsByArticle(int articleNo, {DateTime? lookupDate});
  Future<List<Offense>> getAllOffenses({DateTime? lookupDate});
  Future<Offense?> getOffenseByCode(String offenseCode, {DateTime? lookupDate});
  Future<Offense?> getOffenseById(String id, {DateTime? lookupDate});
  Future<CaseEvaluation> evaluateCase(SearchQueryIntent intent, {DateTime? lookupDate});
}

abstract class ISearchRepository {
  Future<List<Offense>> searchOffenses(String query, {DateTime? lookupDate});
  Future<dynamic> searchFull(String query, {DateTime? lookupDate});
}
