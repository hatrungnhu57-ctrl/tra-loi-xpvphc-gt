import '../enums/vehicle_type.dart';
import '../enums/subject_type.dart';
import '../enums/legal_status.dart';
import 'penalty.dart';
import 'detention_rule.dart';

class Offense {
  final String id;
  final String offenseCode;          // e.g. "MOTO-007-02-G", "CAR-006-05-D", "OWNER-032-10-MOTO"
  final String canonicalName;        // "Chở theo 02 người trên xe mô tô, xe gắn máy"
  final String? shortName;           // "Chở 2 người trên xe máy"
  final String? categoryCode;        // "RULES", "VEHICLE", "DRIVER", "TRANSPORT", "OWNER"
  final SubjectType subjectType;     // driver, ownerIndividual, ownerOrganization...
  final VehicleType vehicleType;     // car, motorcycle, moped...
  final String description;          // Chi tiết hành vi pháp lý
  final String primaryLegalRef;      // "Điểm g Khoản 2 Điều 7"
  final String? primaryProvisionId;
  final String legalDocumentNumber;  // "168/2024/NĐ-CP"
  final String? legalDocumentTitle;  // "Nghị định 168/2024/NĐ-CP (sửa đổi bởi NĐ 238/2026/NĐ-CP)"
  final String? sourceNote;          // Ghi chú sửa đổi, bổ sung

  final List<Penalty> penalties;
  final List<DetentionRule> detentionRules;
  final List<RemedialMeasure> remedialMeasures;
  final List<ExceptionRule> exceptions;
  final List<RelatedOffense> relatedOffenses;
  final List<String> aliases;        // ["kẹp 3", "chở 3", "chở 2 người", "cho 2 nguoi"]
  final List<String> tags;           // ["mũ bảo hiểm", "tốc độ", "cồn"]
  final String searchText;           // Normalized searchable text

  final Map<String, dynamic> conditionJson;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final LegalStatus status;
  final bool reviewed;

  const Offense({
    required this.id,
    required this.offenseCode,
    required this.canonicalName,
    this.shortName,
    this.categoryCode,
    required this.subjectType,
    required this.vehicleType,
    required this.description,
    required this.primaryLegalRef,
    this.primaryProvisionId,
    required this.legalDocumentNumber,
    this.legalDocumentTitle,
    this.sourceNote,
    this.penalties = const [],
    this.detentionRules = const [],
    this.remedialMeasures = const [],
    this.exceptions = const [],
    this.relatedOffenses = const [],
    this.aliases = const [],
    this.tags = const [],
    required this.searchText,
    this.conditionJson = const {},
    this.effectiveFrom,
    this.effectiveTo,
    this.status = LegalStatus.active,
    this.reviewed = true,
  });

  // Helper getters for UI and Engine
  Penalty? get mainFinePenalty {
    try {
      return penalties.firstWhere((p) => p.fineMin != null || p.isWarning);
    } catch (_) {
      return penalties.isNotEmpty ? penalties.first : null;
    }
  }

  int? get fineMin => mainFinePenalty?.fineMin;
  int? get fineMax => mainFinePenalty?.fineMax;
  int? get fineMinOrg => mainFinePenalty?.fineMinOrg;
  int? get fineMaxOrg => mainFinePenalty?.fineMaxOrg;
  bool get isWarning => mainFinePenalty?.isWarning ?? false;

  int? get pointsDeducted {
    for (final p in penalties) {
      if (p.points != null && p.points! > 0) return p.points;
    }
    return null;
  }

  Penalty? get suspensionPenalty {
    for (final p in penalties) {
      if (p.suspensionMinMonths != null) return p;
    }
    return null;
  }

  bool get hasDetention => detentionRules.isNotEmpty;
  bool get hasRemedialMeasures => remedialMeasures.isNotEmpty;
  bool get hasExceptions => exceptions.isNotEmpty;

  String? get accidentRelatedOffenseId {
    for (final rel in relatedOffenses) {
      if (rel.relationType == 'accident_variant') return rel.toOffenseId;
    }
    return null;
  }

  String? get ownerRelatedOffenseId {
    for (final rel in relatedOffenses) {
      if (rel.relationType == 'owner_liability') return rel.toOffenseId;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'offense_code': offenseCode,
    'canonical_name': canonicalName,
    'short_name': shortName,
    'category_code': categoryCode,
    'subject_type': subjectType.code,
    'vehicle_type': vehicleType.code,
    'description': description,
    'primary_legal_ref': primaryLegalRef,
    'primary_provision_id': primaryProvisionId,
    'legal_document_number': legalDocumentNumber,
    'legal_document_title': legalDocumentTitle,
    'source_note': sourceNote,
    'penalties': penalties.map((e) => e.toJson()).toList(),
    'detention_rules': detentionRules.map((e) => e.toJson()).toList(),
    'remedial_measures': remedialMeasures.map((e) => e.toJson()).toList(),
    'exceptions': exceptions.map((e) => e.toJson()).toList(),
    'related_offenses': relatedOffenses.map((e) => e.toJson()).toList(),
    'aliases': aliases,
    'tags': tags,
    'search_text': searchText,
    'condition_json': conditionJson,
    'effective_from': effectiveFrom?.toIso8601String(),
    'effective_to': effectiveTo?.toIso8601String(),
    'status': status.code,
    'reviewed': reviewed,
  };

  factory Offense.fromJson(Map<String, dynamic> json) => Offense(
    id: json['id'] as String,
    offenseCode: json['offense_code'] as String,
    canonicalName: json['canonical_name'] as String,
    shortName: json['short_name'] as String?,
    categoryCode: json['category_code'] as String?,
    subjectType: SubjectType.fromCode(json['subject_type'] as String? ?? 'driver'),
    vehicleType: VehicleType.fromCode(json['vehicle_type'] as String? ?? 'car'),
    description: json['description'] as String,
    primaryLegalRef: json['primary_legal_ref'] as String,
    primaryProvisionId: json['primary_provision_id'] as String?,
    legalDocumentNumber: json['legal_document_number'] as String? ?? '168/2024/NĐ-CP',
    legalDocumentTitle: json['legal_document_title'] as String?,
    sourceNote: json['source_note'] as String?,
    penalties: (json['penalties'] as List<dynamic>? ?? [])
        .map((e) => Penalty.fromJson(e as Map<String, dynamic>))
        .toList(),
    detentionRules: (json['detention_rules'] as List<dynamic>? ?? [])
        .map((e) => DetentionRule.fromJson(e as Map<String, dynamic>))
        .toList(),
    remedialMeasures: (json['remedial_measures'] as List<dynamic>? ?? [])
        .map((e) => RemedialMeasure.fromJson(e as Map<String, dynamic>))
        .toList(),
    exceptions: (json['exceptions'] as List<dynamic>? ?? [])
        .map((e) => ExceptionRule.fromJson(e as Map<String, dynamic>))
        .toList(),
    relatedOffenses: (json['related_offenses'] as List<dynamic>? ?? [])
        .map((e) => RelatedOffense.fromJson(e as Map<String, dynamic>))
        .toList(),
    aliases: (json['aliases'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    searchText: json['search_text'] as String? ?? '',
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
    effectiveFrom: json['effective_from'] != null ? DateTime.parse(json['effective_from']) : null,
    effectiveTo: json['effective_to'] != null ? DateTime.parse(json['effective_to']) : null,
    status: LegalStatus.fromCode(json['status'] as String? ?? 'active'),
    reviewed: json['reviewed'] as bool? ?? true,
  );
}
