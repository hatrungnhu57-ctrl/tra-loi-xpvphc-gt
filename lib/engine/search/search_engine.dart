import '../../domain/entities/offense.dart';
import '../../domain/entities/case_evaluation.dart';
import '../../domain/entities/search_query_intent.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../domain/enums/subject_type.dart';
import '../../core/utils/text_normalizer.dart';
import '../legal/speed_calculator.dart';
import '../legal/alcohol_calculator.dart';
import '../legal/license_checker.dart';
import '../legal/owner_liability_resolver.dart';
import '../legal/case_aggregator.dart';
import '../legal/temporal_resolver.dart';
import 'intent_fact_extractor.dart';

class SearchResultItem {
  final Offense offense;
  final double score;
  final String matchReason;
  final List<String> highlightedTerms;

  const SearchResultItem({
    required this.offense,
    required this.score,
    required this.matchReason,
    this.highlightedTerms = const [],
  });
}

class SearchResponse {
  final SearchQueryIntent intent;
  final List<SearchResultItem> results;
  final CaseEvaluation? caseEvaluation;
  final String explanation;

  const SearchResponse({
    required this.intent,
    required this.results,
    this.caseEvaluation,
    required this.explanation,
  });
}

class SearchEngine {
  final List<Offense> _database;

  SearchEngine(this._database);

  /// Tra cứu toàn diện từ câu truy vấn tự nhiên hoặc citation
  SearchResponse search(String query, {DateTime? lookupDate}) {
    final date = lookupDate ?? DateTime.now();
    final effectiveOffenses = TemporalResolver.filterEffectiveOffenses(_database, date);
    final intent = IntentFactExtractor.extract(query);

    final scoredResults = <SearchResultItem>[];
    final matchedForCase = <Offense>[];
    final relatedOwners = <Offense>[];

    // Priority 1: Nếu có Legal Citation (Điều / Khoản / Điểm)
    if (intent.citation != null && intent.citation!.isNotEmpty) {
      final cit = intent.citation!;
      for (final off in effectiveOffenses) {
        double score = 0;
        if (cit.articleNo != null && off.primaryLegalRef.contains('Điều ${cit.articleNo}')) {
          score += 100;
          if (cit.clauseNo != null && off.primaryLegalRef.contains('Khoản ${cit.clauseNo}')) {
            score += 100;
            if (cit.pointNo != null && (off.primaryLegalRef.toLowerCase().contains('điểm ${cit.pointNo}') || off.offenseCode.toLowerCase().endsWith('-${cit.pointNo}'))) {
              score += 200;
            }
          }
        }
        if (score > 0) {
          scoredResults.add(SearchResultItem(
            offense: off,
            score: score,
            matchReason: 'Khớp căn cứ pháp lý: ${off.primaryLegalRef}',
          ));
          matchedForCase.add(off);
        }
      }
    }

    // Priority 2: Nếu có Fact Tốc độ (Speed)
    if ((intent.speedExcess != null || intent.speedMeasured != null) && scoredResults.isEmpty) {
      final targetVehicle = intent.vehicleType ?? VehicleType.motorcycle;
      final speedResult = SpeedCalculator.evaluate(
        measuredSpeed: intent.speedMeasured ?? ((intent.speedLimit ?? 50) + (intent.speedExcess ?? 0)),
        speedLimit: intent.speedLimit ?? 50,
        vehicleType: targetVehicle,
        causedAccident: intent.causedAccident ?? false,
      );

      if (speedResult != null) {
        for (final off in effectiveOffenses) {
          if (off.primaryLegalRef.contains(speedResult.legalRef) ||
              (off.vehicleType == targetVehicle && off.canonicalName.contains('quá tốc độ') && off.canonicalName.contains(speedResult.speedBracket))) {
            scoredResults.add(SearchResultItem(
              offense: off,
              score: 300,
              matchReason: 'Khớp khung tốc độ: ${speedResult.speedBracket} (${speedResult.legalRef})',
            ));
            matchedForCase.add(off);
          }
        }
      }
    }

    // Priority 3: Nếu có Fact Cồn (Alcohol)
    if ((intent.alcoholBreathMgL != null || intent.alcoholBloodMg100ml != null) && scoredResults.isEmpty) {
      final targetVehicle = intent.vehicleType ?? VehicleType.motorcycle;
      final alcResult = AlcoholCalculator.evaluate(
        breathMgL: intent.alcoholBreathMgL,
        bloodMg100ml: intent.alcoholBloodMg100ml,
        vehicleType: targetVehicle,
      );

      if (alcResult != null) {
        for (final off in effectiveOffenses) {
          if (off.primaryLegalRef.contains(alcResult.legalRef) ||
              (off.vehicleType == targetVehicle && off.canonicalName.contains('nồng độ cồn'))) {
            scoredResults.add(SearchResultItem(
              offense: off,
              score: 300,
              matchReason: 'Khớp khung nồng độ cồn: ${alcResult.level} (${alcResult.legalRef})',
            ));
            matchedForCase.add(off);
          }
        }
      }
    }

    // Priority 4: Nếu có Fact GPLX & Dung tích xi lanh (License & CC)
    if (intent.hasValidLicense == false && !intent.isOwnerLiabilityLookup && scoredResults.isEmpty) {
      final targetVehicle = intent.vehicleType ?? VehicleType.motorcycle;
      final licResult = LicenseChecker.evaluate(
        vehicleType: targetVehicle,
        engineCc: intent.engineCc,
        hasValidLicense: false,
      );

      for (final off in effectiveOffenses) {
        if (off.primaryLegalRef.contains(licResult.legalRef) ||
            (off.categoryCode == 'DRIVER' && off.canonicalName.contains('Không có giấy phép lái xe') && off.vehicleType == targetVehicle)) {
          // Phân biệt rõ >125cc và <=125cc
          if (targetVehicle == VehicleType.motorcycle) {
            final isOver125 = (intent.engineCc != null && intent.engineCc! > 125);
            if (isOver125 && off.offenseCode.contains('OVER-125CC')) {
              scoredResults.add(SearchResultItem(
                offense: off,
                score: 350,
                matchReason: 'Khớp lỗi không GPLX xe mô tô > 125cm3 (${licResult.legalRef})',
              ));
              matchedForCase.add(off);
            } else if (!isOver125 && off.offenseCode.contains('UNDER-125CC')) {
              scoredResults.add(SearchResultItem(
                offense: off,
                score: 350,
                matchReason: 'Khớp lỗi không GPLX xe mô tô <= 125cm3 (${licResult.legalRef})',
              ));
              matchedForCase.add(off);
            }
          } else {
            scoredResults.add(SearchResultItem(
              offense: off,
              score: 350,
              matchReason: 'Khớp lỗi không GPLX (${licResult.legalRef})',
            ));
            matchedForCase.add(off);
          }
        }
      }
    }

    // Priority 5: Nếu có Fact Chủ xe giao xe cho người không bằng (Owner Liability)
    if (intent.isOwnerLiabilityLookup && intent.hasValidLicense == false && scoredResults.isEmpty) {
      final targetVehicle = intent.vehicleType ?? VehicleType.motorcycle;
      final ownerRes = OwnerLiabilityResolver.resolveUnqualifiedDriverHandover(vehicleType: targetVehicle);

      for (final off in effectiveOffenses) {
        if (off.primaryLegalRef.contains(ownerRes.legalRef) ||
            (off.subjectType == SubjectType.ownerIndividual && off.canonicalName.contains('giao xe'))) {
          scoredResults.add(SearchResultItem(
            offense: off,
            score: 350,
            matchReason: 'Khớp trách nhiệm chủ phương tiện giao xe: ${ownerRes.legalRef}',
          ));
          matchedForCase.add(off);
        }
      }
    }

    // Priority 6: Nếu có Fact Số người (Passenger count - "kẹp 3", "chở 3")
    if (intent.passengerCount != null && scoredResults.isEmpty) {
      final count = intent.passengerCount!;
      for (final off in effectiveOffenses) {
        if (count >= 3 && (off.offenseCode.contains('MOTO-007-03-B') || off.canonicalName.contains('từ 03 người trở lên'))) {
          scoredResults.add(SearchResultItem(
            offense: off,
            score: 300,
            matchReason: 'Khớp hành vi chở từ 03 người trở lên (kẹp 3) trên xe mô tô (Điểm b Khoản 3 Điều 7)',
          ));
          matchedForCase.add(off);
        } else if (count == 2 && (off.offenseCode.contains('MOTO-007-02-G') || off.canonicalName.contains('chở theo 02 người'))) {
          scoredResults.add(SearchResultItem(
            offense: off,
            score: 300,
            matchReason: 'Khớp hành vi chở theo 02 người trên xe mô tô (Điểm g Khoản 2 Điều 7)',
          ));
          matchedForCase.add(off);
        }
      }
    }

    // Priority 7: Keyword / Alias / Full text matching
    if (scoredResults.isEmpty) {
      final queryTokens = TextNormalizer.removeDiacritics(intent.normalizedQuery).split(' ');
      for (final off in effectiveOffenses) {
        double score = 0;
        final offSearchText = TextNormalizer.removeDiacritics(off.searchText);

        // Check vehicle filter
        if (intent.vehicleType != null && off.vehicleType != intent.vehicleType && off.vehicleType != VehicleType.all) {
          continue;
        }

        // Khớp Alias
        for (final alias in off.aliases) {
          final aliasNorm = TextNormalizer.removeDiacritics(alias);
          if (intent.normalizedQuery.contains(alias) || TextNormalizer.removeDiacritics(intent.normalizedQuery).contains(aliasNorm)) {
            score += 80;
          }
        }

        // Khớp Tags
        for (final tag in off.tags) {
          final tagNorm = TextNormalizer.removeDiacritics(tag);
          if (TextNormalizer.removeDiacritics(intent.normalizedQuery).contains(tagNorm)) {
            score += 50;
          }
        }

        // Token matching
        int matchedTokens = 0;
        for (final token in queryTokens) {
          if (token.length > 1 && offSearchText.contains(token)) {
            matchedTokens++;
          }
        }
        if (matchedTokens > 0) {
          score += (matchedTokens / queryTokens.length) * 50;
        }

        if (score > 20) {
          scoredResults.add(SearchResultItem(
            offense: off,
            score: score,
            matchReason: 'Khớp từ khóa và tên hành vi',
          ));
          matchedForCase.add(off);
        }
      }
    }

    // Sắp xếp kết quả theo điểm số giảm dần
    scoredResults.sort((a, b) => b.score.compareTo(a.score));

    // Tìm các lỗi của chủ xe liên quan (nếu có)
    for (final off in matchedForCase) {
      final ownerId = off.ownerRelatedOffenseId;
      if (ownerId != null) {
        try {
          final ownerOff = effectiveOffenses.firstWhere(
            (o) => o.id == ownerId || o.offenseCode == ownerId,
          );
          if (!relatedOwners.contains(ownerOff)) relatedOwners.add(ownerOff);
        } catch (_) {}
      }
    }

    // Tính toán CaseEvaluation tổng hợp
    CaseEvaluation? evaluation;
    if (matchedForCase.isNotEmpty) {
      evaluation = CaseAggregator.aggregate(
        matchedOffenses: matchedForCase,
        relatedOwnerOffenses: relatedOwners,
        evaluationDate: date,
      );
    }

    return SearchResponse(
      intent: intent,
      results: scoredResults,
      caseEvaluation: evaluation,
      explanation: _buildExplanation(intent, scoredResults, evaluation),
    );
  }

  String _buildExplanation(
    SearchQueryIntent intent,
    List<SearchResultItem> results,
    CaseEvaluation? eval,
  ) {
    if (results.isEmpty) {
      return 'Không tìm thấy hành vi vi phạm phù hợp với truy vấn: "${intent.rawQuery}".';
    }
    final top = results.first;
    return 'Tìm thấy ${results.length} hành vi phù hợp. Kết quả hàng đầu: ${top.offense.canonicalName} (${top.offense.primaryLegalRef}). ${top.matchReason}.';
  }
}
