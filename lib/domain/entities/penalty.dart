import '../enums/penalty_type.dart';

class Penalty {
  final String id;
  final String offenseId;
  final PenaltyType penaltyType;
  final bool isWarning;
  final int? fineMin;             // Tiền phạt tối thiểu cá nhân (VNĐ)
  final int? fineMax;             // Tiền phạt tối đa cá nhân (VNĐ)
  final int? fineMinOrg;          // Tiền phạt tối thiểu tổ chức (VNĐ, nếu có)
  final int? fineMaxOrg;          // Tiền phạt tối đa tổ chức (VNĐ, nếu có)
  final int? points;              // Trừ điểm GPLX (02, 03, 04, 06, 08, 10 điểm)
  final double? suspensionMinMonths; // Tước GPLX tối thiểu (tháng)
  final double? suspensionMaxMonths; // Tước GPLX tối đa (tháng)
  final String? confiscationTarget;  // Tang vật / Phương tiện bị tịch thu
  final Map<String, dynamic> conditionJson;
  final String? notes;

  const Penalty({
    required this.id,
    required this.offenseId,
    required this.penaltyType,
    this.isWarning = false,
    this.fineMin,
    this.fineMax,
    this.fineMinOrg,
    this.fineMaxOrg,
    this.points,
    this.suspensionMinMonths,
    this.suspensionMaxMonths,
    this.confiscationTarget,
    this.conditionJson = const {},
    this.notes,
  });

  String get fineRangeText {
    if (isWarning || penaltyType == PenaltyType.warning) {
      return 'Phạt cảnh cáo';
    }
    if (fineMin != null && fineMax != null) {
      if (fineMin == fineMax) {
        return '${_formatVND(fineMin!)} đồng';
      }
      return '${_formatVND(fineMin!)} - ${_formatVND(fineMax!)} đồng';
    }
    return '';
  }

  String get orgFineRangeText {
    if (fineMinOrg != null && fineMaxOrg != null) {
      if (fineMinOrg == fineMaxOrg) {
        return '${_formatVND(fineMinOrg!)} đồng (Tổ chức)';
      }
      return '${_formatVND(fineMinOrg!)} - ${_formatVND(fineMaxOrg!)} đồng (Tổ chức)';
    }
    return '';
  }

  static String _formatVND(int amount) {
    if (amount >= 1000000) {
      final trieu = amount / 1000000;
      return trieu == trieu.toInt()
          ? '${trieu.toInt()} triệu'
          : '${trieu.toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      final nghin = amount / 1000;
      return nghin == nghin.toInt()
          ? '${nghin.toInt()} nghìn'
          : '${nghin.toStringAsFixed(0)} nghìn';
    }
    return amount.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'offense_id': offenseId,
    'penalty_type': penaltyType.code,
    'is_warning': isWarning,
    'fine_min': fineMin,
    'fine_max': fineMax,
    'fine_min_org': fineMinOrg,
    'fine_max_org': fineMaxOrg,
    'points': points,
    'suspension_min_months': suspensionMinMonths,
    'suspension_max_months': suspensionMaxMonths,
    'confiscation_target': confiscationTarget,
    'condition_json': conditionJson,
    'notes': notes,
  };

  factory Penalty.fromJson(Map<String, dynamic> json) => Penalty(
    id: json['id'] as String,
    offenseId: json['offense_id'] as String,
    penaltyType: PenaltyType.fromCode(json['penalty_type'] as String? ?? 'fine'),
    isWarning: json['is_warning'] as bool? ?? false,
    fineMin: json['fine_min'] as int?,
    fineMax: json['fine_max'] as int?,
    fineMinOrg: json['fine_min_org'] as int?,
    fineMaxOrg: json['fine_max_org'] as int?,
    points: json['points'] as int?,
    suspensionMinMonths: (json['suspension_min_months'] as num?)?.toDouble(),
    suspensionMaxMonths: (json['suspension_max_months'] as num?)?.toDouble(),
    confiscationTarget: json['confiscation_target'] as String?,
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
    notes: json['notes'] as String?,
  );
}
