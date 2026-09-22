import '../../domain/entities/offense.dart';
import '../../domain/entities/provision.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/entities/case_evaluation.dart';
import '../../domain/entities/search_query_intent.dart';
import '../../domain/repositories/i_legal_repository.dart';
import '../../engine/legal/legal_engine.dart';
import '../../engine/legal/temporal_resolver.dart';
import '../datasources/seed_data_loader.dart';

class LegalRepositoryImpl implements ILegalRepository {
  List<Offense> _offenses = [];

  LegalRepositoryImpl([List<Offense>? initialOffenses]) {
    _offenses = initialOffenses ?? SeedDataLoader.getSeedOffenses();
  }

  @override
  Future<List<LegalDocument>> getAllDocuments() async {
    return [
      LegalDocument(
        id: 'doc_nd168',
        documentNumber: '168/2024/NĐ-CP',
        documentType: 'Nghị định',
        title: 'Quy định xử phạt vi phạm hành chính về trật tự, an toàn giao thông trong lĩnh vực giao thông đường bộ; trừ điểm, phục hồi điểm giấy phép lái xe',
        issuer: 'Chính phủ',
        issuedDate: DateTime(2024, 12, 26),
        effectiveFrom: DateTime(2025, 1, 1),
      ),
      LegalDocument(
        id: 'doc_nd238',
        documentNumber: '238/2026/NĐ-CP',
        documentType: 'Nghị định',
        title: 'Sửa đổi, bổ sung một số điều của Nghị định số 168/2024/NĐ-CP',
        issuer: 'Chính phủ',
        issuedDate: DateTime(2026, 6, 26),
        effectiveFrom: DateTime(2026, 8, 15),
      ),
    ];
  }

  @override
  Future<List<Offense>> getAllOffenses({DateTime? lookupDate}) async {
    if (lookupDate != null) {
      return TemporalResolver.filterEffectiveOffenses(_offenses, lookupDate);
    }
    return _offenses;
  }

  @override
  Future<Offense?> getOffenseByCode(String offenseCode, {DateTime? lookupDate}) async {
    final list = await getAllOffenses(lookupDate: lookupDate);
    try {
      return list.firstWhere((o) => o.offenseCode == offenseCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Offense?> getOffenseById(String id, {DateTime? lookupDate}) async {
    final list = await getAllOffenses(lookupDate: lookupDate);
    try {
      return list.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Provision>> getProvisionsByArticle(int articleNo, {DateTime? lookupDate}) async {
    return [];
  }

  @override
  Future<CaseEvaluation> evaluateCase(SearchQueryIntent intent, {DateTime? lookupDate}) async {
    final list = await getAllOffenses(lookupDate: lookupDate);
    return LegalEngine.evaluateIntent(
      intent: intent,
      availableOffenses: list,
      lookupDate: lookupDate,
    );
  }
}
