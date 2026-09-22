import '../../domain/entities/offense.dart';
import '../../domain/entities/case_evaluation.dart';
import '../../domain/entities/search_query_intent.dart';
import '../../core/dsl/condition_evaluator.dart';
import 'speed_calculator.dart';
import 'alcohol_calculator.dart';
import 'license_checker.dart';
import 'owner_liability_resolver.dart';
import 'accident_variant_resolver.dart';
import 'case_aggregator.dart';
import 'temporal_resolver.dart';

class LegalEngine {
  /// Đánh giá tình huống từ SearchQueryIntent và tập dữ liệu pháp luật
  static CaseEvaluation evaluateIntent({
    required SearchQueryIntent intent,
    required List<Offense> availableOffenses,
    DateTime? lookupDate,
  }) {
    final date = lookupDate ?? DateTime.now();

    // 1. Lọc các quy định đang có hiệu lực tại ngày tra cứu
    final effectiveOffenses = TemporalResolver.filterEffectiveOffenses(availableOffenses, date);

    final matched = <Offense>[];
    final relatedOwners = <Offense>[];

    // 2. Chuyển đổi intent facts thành facts map cho Condition DSL
    final facts = <String, dynamic>{
      'vehicle.group': intent.vehicleType?.code,
      'subject': intent.subjectType?.code,
      'speed_measured': intent.speedMeasured,
      'speed_limit': intent.speedLimit,
      'speed_excess': intent.speedExcess,
      'alcohol_breath': intent.alcoholBreathMgL,
      'alcohol_blood': intent.alcoholBloodMg100ml,
      'engine_cc': intent.engineCc,
      'power_kw': intent.powerKw,
      'passenger_count': intent.passengerCount,
      'has_valid_license': intent.hasValidLicense,
      'caused_accident': intent.causedAccident ?? false,
      'has_helmet': intent.hasHelmet,
    };

    // 3. Đánh giá từng offense bằng Condition Evaluator
    for (final off in effectiveOffenses) {
      if (off.conditionJson.isNotEmpty) {
        if (ConditionEvaluator.evaluate(off.conditionJson, facts)) {
          // Nếu có cờ gây tai nạn, kiểm tra xem có chuyển sang accident variant không
          if (intent.causedAccident == true) {
            final accVariant = AccidentVariantResolver.resolveAccidentVariant(off, effectiveOffenses);
            if (accVariant != null) {
              if (!matched.contains(accVariant)) matched.add(accVariant);
              continue;
            }
          }
          if (!matched.contains(off)) matched.add(off);
        }
      }
    }

    // 4. Nếu có liên quan đến lỗi chủ xe (hoặc intent hỏi về chủ xe)
    if (intent.isOwnerLiabilityLookup || intent.hasValidLicense == false) {
      for (final off in matched) {
        final ownerRelId = off.ownerRelatedOffenseId;
        if (ownerRelId != null) {
          try {
            final ownerOff = effectiveOffenses.firstWhere(
              (o) => o.id == ownerRelId || o.offenseCode == ownerRelId,
            );
            if (!relatedOwners.contains(ownerOff)) relatedOwners.add(ownerOff);
          } catch (_) {}
        }
      }
    }

    // 5. Tổng hợp vụ việc
    return CaseAggregator.aggregate(
      matchedOffenses: matched,
      relatedOwnerOffenses: relatedOwners,
      evaluationDate: date,
    );
  }
}
