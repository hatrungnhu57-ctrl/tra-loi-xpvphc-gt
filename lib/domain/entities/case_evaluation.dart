import 'offense.dart';
import 'penalty.dart';
import 'detention_rule.dart';
import 'remedial_measure.dart';

class CaseEvaluation {
  final List<Offense> matchedOffenses;
  final int totalFineMinIndividual;
  final int totalFineMaxIndividual;
  final int totalFineMinOrganization;
  final int totalFineMaxOrganization;
  final bool isWarningOnly;

  // Điều 50.1.b: Chỉ trừ điểm hành vi bị trừ nhiều điểm nhất
  final int? maxPointsDeducted;
  final String? pointsDeductedLegalBasis;

  // Điều 5.2 & Điều 50.1.đ: Nếu có tước GPLX và trừ điểm thì chỉ tước GPLX
  final bool hasLicenseSuspension;
  final double? maxSuspensionMonthsMin;
  final double? maxSuspensionMonthsMax;
  final String? suspensionLegalBasis;
  final bool pointsOverriddenBySuspension;

  // Điều 48: Tạm giữ
  final List<DetentionRule> activeDetentions;

  // Biện pháp khắc phục
  final List<RemedialMeasure> activeRemedialMeasures;

  // Trách nhiệm chủ xe liên quan (Điều 32)
  final List<Offense> relatedOwnerOffenses;

  // Giải thích căn cứ pháp lý tổng hợp
  final List<String> legalExplanations;
  final DateTime evaluationDate;

  const CaseEvaluation({
    required this.matchedOffenses,
    required this.totalFineMinIndividual,
    required this.totalFineMaxIndividual,
    required this.totalFineMinOrganization,
    required this.totalFineMaxOrganization,
    this.isWarningOnly = false,
    this.maxPointsDeducted,
    this.pointsDeductedLegalBasis,
    this.hasLicenseSuspension = false,
    this.maxSuspensionMonthsMin,
    this.maxSuspensionMonthsMax,
    this.suspensionLegalBasis,
    this.pointsOverriddenBySuspension = false,
    this.activeDetentions = const [],
    this.activeRemedialMeasures = const [],
    this.relatedOwnerOffenses = const [],
    this.legalExplanations = const [],
    required this.evaluationDate,
  });

  String get individualFineSummary {
    if (isWarningOnly) return 'Phạt cảnh cáo';
    if (totalFineMinIndividual == 0 && totalFineMaxIndividual == 0) return 'Không có phạt tiền';
    return '${Penalty._formatVND(totalFineMinIndividual)} - ${Penalty._formatVND(totalFineMaxIndividual)} đồng';
  }

  String get organizationFineSummary {
    if (totalFineMinOrganization == 0 && totalFineMaxOrganization == 0) return '';
    return '${Penalty._formatVND(totalFineMinOrganization)} - ${Penalty._formatVND(totalFineMaxOrganization)} đồng';
  }

  Map<String, dynamic> toJson() => {
    'matched_offenses': matchedOffenses.map((e) => e.toJson()).toList(),
    'total_fine_min_individual': totalFineMinIndividual,
    'total_fine_max_individual': totalFineMaxIndividual,
    'total_fine_min_org': totalFineMinOrganization,
    'total_fine_max_org': totalFineMaxOrganization,
    'is_warning_only': isWarningOnly,
    'max_points_deducted': maxPointsDeducted,
    'points_legal_basis': pointsDeductedLegalBasis,
    'has_license_suspension': hasLicenseSuspension,
    'suspension_min_months': maxSuspensionMonthsMin,
    'suspension_max_months': maxSuspensionMonthsMax,
    'suspension_legal_basis': suspensionLegalBasis,
    'points_overridden_by_suspension': pointsOverriddenBySuspension,
    'active_detentions': activeDetentions.map((e) => e.toJson()).toList(),
    'active_remedial_measures': activeRemedialMeasures.map((e) => e.toJson()).toList(),
    'related_owner_offenses': relatedOwnerOffenses.map((e) => e.toJson()).toList(),
    'legal_explanations': legalExplanations,
    'evaluation_date': evaluationDate.toIso8601String(),
  };
}
