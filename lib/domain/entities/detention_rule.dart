import '../enums/detention_target.dart';

class DetentionRule {
  final String id;
  final String offenseId;
  final DetentionTarget detentionTarget; // vehicle, driving_license, vehicle_registration...
  final DetentionPurpose purpose;       // prevent, ensure_execution, verify
  final String? legalBasisProvisionId;  // Provision ID (e.g. Điều 48.1.a, Điều 48.1.i...)
  final String legalBasisText;          // "Khoản 1 Điều 48"
  final Map<String, dynamic> conditionJson;
  final String? note;                   // "Tạm giữ đến 07 ngày trước khi ra quyết định"

  const DetentionRule({
    required this.id,
    required this.offenseId,
    this.detentionTarget = DetentionTarget.vehicle,
    this.purpose = DetentionPurpose.prevent,
    this.legalBasisProvisionId,
    required this.legalBasisText,
    this.conditionJson = const {},
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offense_id': offenseId,
    'detention_target': detentionTarget.code,
    'purpose': purpose.code,
    'legal_basis_provision_id': legalBasisProvisionId,
    'legal_basis_text': legalBasisText,
    'condition_json': conditionJson,
    'note': note,
  };

  factory DetentionRule.fromJson(Map<String, dynamic> json) => DetentionRule(
    id: json['id'] as String,
    offenseId: json['offense_id'] as String,
    detentionTarget: DetentionTarget.fromCode(json['detention_target'] as String? ?? 'vehicle'),
    purpose: DetentionPurpose.fromCode(json['purpose'] as String? ?? 'prevent'),
    legalBasisProvisionId: json['legal_basis_provision_id'] as String?,
    legalBasisText: json['legal_basis_text'] as String? ?? 'Điều 48',
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
    note: json['note'] as String?,
  );
}

class RemedialMeasure {
  final String id;
  final String offenseId;
  final String measureCode;   // e.g. "RESTORE_ORIGINAL_PAINT", "DISMANTLE_ILLEGAL_LIGHTS"
  final String description;   // "Buộc khôi phục lại màu sơn ghi trong giấy đăng ký xe"
  final String? provisionId;  // Provision ID (e.g. Điều 3 Khoản 3 Điểm n)
  final String legalBasisText;// "Điểm n Khoản 3 Điều 3"
  final Map<String, dynamic> conditionJson;

  const RemedialMeasure({
    required this.id,
    required this.offenseId,
    required this.measureCode,
    required this.description,
    this.provisionId,
    required this.legalBasisText,
    this.conditionJson = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offense_id': offenseId,
    'measure_code': measureCode,
    'description': description,
    'provision_id': provisionId,
    'legal_basis_text': legalBasisText,
    'condition_json': conditionJson,
  };

  factory RemedialMeasure.fromJson(Map<String, dynamic> json) => RemedialMeasure(
    id: json['id'] as String,
    offenseId: json['offense_id'] as String,
    measureCode: json['measure_code'] as String,
    description: json['description'] as String,
    provisionId: json['provision_id'] as String?,
    legalBasisText: json['legal_basis_text'] as String? ?? 'Điều 3 Khoản 3',
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
  );
}

class ExceptionRule {
  final String id;
  final String offenseId;
  final String exceptionCode; // e.g. "EMERGENCY_PATIENT", "CHILD_UNDER_12"
  final String description;   // "Trường hợp chở người bệnh đi cấp cứu, trẻ em dưới 12 tuổi..."
  final Map<String, dynamic> conditionJson;
  final String? provisionId;

  const ExceptionRule({
    required this.id,
    required this.offenseId,
    required this.exceptionCode,
    required this.description,
    this.conditionJson = const {},
    this.provisionId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offense_id': offenseId,
    'exception_code': exceptionCode,
    'description': description,
    'condition_json': conditionJson,
    'provision_id': provisionId,
  };

  factory ExceptionRule.fromJson(Map<String, dynamic> json) => ExceptionRule(
    id: json['id'] as String,
    offenseId: json['offense_id'] as String,
    exceptionCode: json['exception_code'] as String,
    description: json['description'] as String,
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
    provisionId: json['provision_id'] as String?,
  );
}

class RelatedOffense {
  final String fromOffenseId;
  final String toOffenseId;
  final String relationType; // "owner_liability", "accident_variant", "document_resolution"
  final String description;
  final Map<String, dynamic> conditionJson;

  const RelatedOffense({
    required this.fromOffenseId,
    required this.toOffenseId,
    required this.relationType,
    required this.description,
    this.conditionJson = const {},
  });

  Map<String, dynamic> toJson() => {
    'from_offense_id': fromOffenseId,
    'to_offense_id': toOffenseId,
    'relation_type': relationType,
    'description': description,
    'condition_json': conditionJson,
  };

  factory RelatedOffense.fromJson(Map<String, dynamic> json) => RelatedOffense(
    fromOffenseId: json['from_offense_id'] as String,
    toOffenseId: json['to_offense_id'] as String,
    relationType: json['relation_type'] as String,
    description: json['description'] as String? ?? '',
    conditionJson: json['condition_json'] as Map<String, dynamic>? ?? const {},
  );
}
