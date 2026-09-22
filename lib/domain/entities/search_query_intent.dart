import '../enums/vehicle_type.dart';
import '../enums/subject_type.dart';

class LegalCitation {
  final int? articleNo;   // 6, 7, 18, 32, 48...
  final String? clauseNo; // "1", "1a", "2", "3"...
  final String? pointNo;  // "a", "b", "c", "d", "đ", "e", "g"...

  const LegalCitation({
    this.articleNo,
    this.clauseNo,
    this.pointNo,
  });

  bool get isEmpty => articleNo == null && clauseNo == null && pointNo == null;
  bool get isNotEmpty => !isEmpty;

  String toFullCitation() {
    final parts = <String>[];
    if (pointNo != null && pointNo!.isNotEmpty) parts.add('Điểm $pointNo');
    if (clauseNo != null && clauseNo!.isNotEmpty) parts.add('Khoản $clauseNo');
    if (articleNo != null) parts.add('Điều $articleNo');
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
    'article_no': articleNo,
    'clause_no': clauseNo,
    'point_no': pointNo,
  };
}

class SearchQueryIntent {
  final String rawQuery;
  final String normalizedQuery;
  final VehicleType? vehicleType;
  final SubjectType? subjectType;
  final LegalCitation? citation;

  // Facts trích xuất
  final double? speedMeasured;
  final double? speedLimit;
  final double? speedExcess;
  final double? alcoholBreathMgL;
  final double? alcoholBloodMg100ml;
  final double? engineCc;
  final double? powerKw;
  final int? passengerCount;
  final bool? hasValidLicense;
  final bool? licenseExpiredUnder1Year;
  final bool? hasHelmet;
  final bool? causedAccident;
  final bool isOwnerLiabilityLookup;
  final bool isProceduralDocumentLookup;
  final List<String> extractedKeywords;
  final bool needsReview;

  const SearchQueryIntent({
    required this.rawQuery,
    required this.normalizedQuery,
    this.vehicleType,
    this.subjectType,
    this.citation,
    this.speedMeasured,
    this.speedLimit,
    this.speedExcess,
    this.alcoholBreathMgL,
    this.alcoholBloodMg100ml,
    this.engineCc,
    this.powerKw,
    this.passengerCount,
    this.hasValidLicense,
    this.licenseExpiredUnder1Year,
    this.hasHelmet,
    this.causedAccident,
    this.isOwnerLiabilityLookup = false,
    this.isProceduralDocumentLookup = false,
    this.extractedKeywords = const [],
    this.needsReview = false,
  });

  Map<String, dynamic> toJson() => {
    'raw_query': rawQuery,
    'normalized_query': normalizedQuery,
    'vehicle_type': vehicleType?.code,
    'subject_type': subjectType?.code,
    'citation': citation?.toJson(),
    'speed_measured': speedMeasured,
    'speed_limit': speedLimit,
    'speed_excess': speedExcess,
    'alcohol_breath_mgl': alcoholBreathMgL,
    'alcohol_blood_mg100ml': alcoholBloodMg100ml,
    'engine_cc': engineCc,
    'power_kw': powerKw,
    'passenger_count': passengerCount,
    'has_valid_license': hasValidLicense,
    'license_expired_under_1_year': licenseExpiredUnder1Year,
    'has_helmet': hasHelmet,
    'caused_accident': causedAccident,
    'is_owner_liability_lookup': isOwnerLiabilityLookup,
    'is_procedural_doc_lookup': isProceduralDocumentLookup,
    'extracted_keywords': extractedKeywords,
    'needs_review': needsReview,
  };
}
