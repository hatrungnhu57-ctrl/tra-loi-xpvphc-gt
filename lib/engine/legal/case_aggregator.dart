import 'dart:math';
import '../../domain/entities/offense.dart';
import '../../domain/entities/case_evaluation.dart';
import '../../domain/entities/detention_rule.dart';
import '../../domain/entities/remedial_measure.dart';
import '../../domain/enums/penalty_type.dart';

class CaseAggregator {
  /// Tổng hợp vụ việc theo đúng các nguyên tắc của Nghị định 168/2024 & 238/2026
  static CaseEvaluation aggregate({
    required List<Offense> matchedOffenses,
    List<Offense> relatedOwnerOffenses = const [],
    DateTime? evaluationDate,
  }) {
    final date = evaluationDate ?? DateTime.now();

    if (matchedOffenses.isEmpty) {
      return CaseEvaluation(
        matchedOffenses: const [],
        totalFineMinIndividual: 0,
        totalFineMaxIndividual: 0,
        totalFineMinOrganization: 0,
        totalFineMaxOrganization: 0,
        evaluationDate: date,
      );
    }

    int totalFineMinInd = 0;
    int totalFineMaxInd = 0;
    int totalFineMinOrg = 0;
    int totalFineMaxOrg = 0;
    bool allWarning = true;

    bool hasSuspension = false;
    double maxSuspensionMin = 0.0;
    double maxSuspensionMax = 0.0;
    String? suspensionBasis;

    int maxPoints = 0;
    String? maxPointsBasis;

    final detentions = <DetentionRule>[];
    final remedialMeasures = <RemedialMeasure>[];
    final explanations = <String>[];

    for (final off in matchedOffenses) {
      explanations.add('Hành vi: ${off.canonicalName} (${off.primaryLegalRef})');

      // 1. Tính tiền phạt từng hành vi
      final finePen = off.mainFinePenalty;
      if (finePen != null) {
        if (!finePen.isWarning && finePen.penaltyType != PenaltyType.warning) {
          allWarning = false;
          totalFineMinInd += finePen.fineMin ?? 0;
          totalFineMaxInd += finePen.fineMax ?? 0;
          totalFineMinOrg += finePen.fineMinOrg ?? finePen.fineMin ?? 0;
          totalFineMaxOrg += finePen.fineMaxOrg ?? finePen.fineMax ?? 0;
        }
      } else {
        allWarning = false;
      }

      // 2. Kiểm tra tước GPLX
      final suspPen = off.suspensionPenalty;
      if (suspPen != null) {
        hasSuspension = true;
        if ((suspPen.suspensionMinMonths ?? 0) > maxSuspensionMin) {
          maxSuspensionMin = suspPen.suspensionMinMonths!;
          maxSuspensionMax = suspPen.suspensionMaxMonths ?? suspPen.suspensionMinMonths!;
          suspensionBasis = off.primaryLegalRef;
        }
      }

      // 3. Kiểm tra trừ điểm GPLX
      final pts = off.pointsDeducted;
      if (pts != null && pts > maxPoints) {
        maxPoints = pts;
        maxPointsBasis = off.primaryLegalRef;
      }

      // 4. Tổng hợp tạm giữ
      detentions.addAll(off.detentionRules);

      // 5. Tổng hợp biện pháp khắc phục
      remedialMeasures.addAll(off.remedialMeasures);
    }

    // Áp dụng Điều 5.2 & Điều 50.1.đ: Nếu có tước GPLX thì KHÔNG trừ điểm GPLX
    bool pointsOverridden = false;
    int? finalPoints;
    String? pointsBasis;

    if (hasSuspension) {
      pointsOverridden = true;
      finalPoints = null;
      pointsBasis = null;
      explanations.add(
        'Áp dụng Khoản 2 Điều 5 & Điểm đ Khoản 1 Điều 50: Có hành vi bị tước quyền sử dụng GPLX nên CHỈ áp dụng tước GPLX, không trừ điểm GPLX.',
      );
    } else if (maxPoints > 0) {
      finalPoints = maxPoints;
      pointsBasis = maxPointsBasis;
      if (matchedOffenses.where((o) => (o.pointsDeducted ?? 0) > 0).length > 1) {
        explanations.add(
          'Áp dụng Điểm b Khoản 1 Điều 50: Nhiều hành vi cùng bị trừ điểm trong một lần xử phạt -> Chỉ trừ điểm hành vi bị trừ nhiều nhất ($maxPoints điểm theo $maxPointsBasis).',
        );
      }
    }

    return CaseEvaluation(
      matchedOffenses: matchedOffenses,
      totalFineMinIndividual: totalFineMinInd,
      totalFineMaxIndividual: totalFineMaxInd,
      totalFineMinOrganization: totalFineMinOrg,
      totalFineMaxOrganization: totalFineMaxOrg,
      isWarningOnly: allWarning && matchedOffenses.isNotEmpty,
      maxPointsDeducted: finalPoints,
      pointsDeductedLegalBasis: pointsBasis,
      hasLicenseSuspension: hasSuspension,
      maxSuspensionMonthsMin: hasSuspension ? maxSuspensionMin : null,
      maxSuspensionMonthsMax: hasSuspension ? maxSuspensionMax : null,
      suspensionLegalBasis: suspensionBasis,
      pointsOverriddenBySuspension: pointsOverridden,
      activeDetentions: detentions,
      activeRemedialMeasures: remedialMeasures,
      relatedOwnerOffenses: relatedOwnerOffenses,
      legalExplanations: explanations,
      evaluationDate: date,
    );
  }
}
