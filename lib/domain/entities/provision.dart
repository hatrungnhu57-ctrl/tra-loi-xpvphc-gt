import '../enums/legal_status.dart';

class LegalDocument {
  final String id;
  final String documentNumber; // e.g. "168/2024/NĐ-CP", "238/2026/NĐ-CP"
  final String documentType;   // "Nghị định"
  final String title;
  final String? issuer;        // "Chính phủ"
  final DateTime? issuedDate;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final String? officialSourceUrl;
  final String? sourceFileHash;
  final LegalStatus status;

  const LegalDocument({
    required this.id,
    required this.documentNumber,
    required this.documentType,
    required this.title,
    this.issuer,
    this.issuedDate,
    this.effectiveFrom,
    this.effectiveTo,
    this.officialSourceUrl,
    this.sourceFileHash,
    this.status = LegalStatus.active,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'document_number': documentNumber,
    'document_type': documentType,
    'title': title,
    'issuer': issuer,
    'issued_date': issuedDate?.toIso8601String(),
    'effective_from': effectiveFrom?.toIso8601String(),
    'effective_to': effectiveTo?.toIso8601String(),
    'official_source_url': officialSourceUrl,
    'source_file_hash': sourceFileHash,
    'status': status.code,
  };

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    id: json['id'] as String,
    documentNumber: json['document_number'] as String,
    documentType: json['document_type'] as String,
    title: json['title'] as String,
    issuer: json['issuer'] as String?,
    issuedDate: json['issued_date'] != null ? DateTime.parse(json['issued_date']) : null,
    effectiveFrom: json['effective_from'] != null ? DateTime.parse(json['effective_from']) : null,
    effectiveTo: json['effective_to'] != null ? DateTime.parse(json['effective_to']) : null,
    officialSourceUrl: json['official_source_url'] as String?,
    sourceFileHash: json['source_file_hash'] as String?,
    status: LegalStatus.fromCode(json['status'] as String? ?? 'active'),
  );
}

class Provision {
  final String id;
  final String documentId;
  final String? parentId;
  final int? chapterNo;
  final int? sectionNo;
  final int? articleNo;        // e.g. 6, 7, 18, 32, 48
  final String? clauseNo;      // e.g. "1", "1a", "2", "3"
  final String? pointNo;       // e.g. "a", "b", "c", "d", "đ", "e", "g", "h", "i", "k", "l", "m", "n", "o", "p", "q"
  final String? subpointNo;
  final String? heading;
  final String bodyText;
  final String normalizedText;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final LegalStatus provisionStatus;
  final int? sourcePage;
  final String? sourceNote;    // e.g. "Sửa đổi bởi NĐ 238/2026/NĐ-CP"
  final String? sortPath;

  const Provision({
    required this.id,
    required this.documentId,
    this.parentId,
    this.chapterNo,
    this.sectionNo,
    this.articleNo,
    this.clauseNo,
    this.pointNo,
    this.subpointNo,
    this.heading,
    required this.bodyText,
    required this.normalizedText,
    this.effectiveFrom,
    this.effectiveTo,
    this.provisionStatus = LegalStatus.active,
    this.sourcePage,
    this.sourceNote,
    this.sortPath,
  });

  String get citation {
    final parts = <String>[];
    if (pointNo != null && pointNo!.isNotEmpty) {
      parts.add('Điểm $pointNo');
    }
    if (clauseNo != null && clauseNo!.isNotEmpty) {
      parts.add('Khoản $clauseNo');
    }
    if (articleNo != null) {
      parts.add('Điều $articleNo');
    }
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'document_id': documentId,
    'parent_id': parentId,
    'chapter_no': chapterNo,
    'section_no': sectionNo,
    'article_no': articleNo,
    'clause_no': clauseNo,
    'point_no': pointNo,
    'subpoint_no': subpointNo,
    'heading': heading,
    'body_text': bodyText,
    'normalized_text': normalizedText,
    'effective_from': effectiveFrom?.toIso8601String(),
    'effective_to': effectiveTo?.toIso8601String(),
    'provision_status': provisionStatus.code,
    'source_page': sourcePage,
    'source_note': sourceNote,
    'sort_path': sortPath,
  };

  factory Provision.fromJson(Map<String, dynamic> json) => Provision(
    id: json['id'] as String,
    documentId: json['document_id'] as String,
    parentId: json['parent_id'] as String?,
    chapterNo: json['chapter_no'] as int?,
    sectionNo: json['section_no'] as int?,
    articleNo: json['article_no'] as int?,
    clauseNo: json['clause_no']?.toString(),
    pointNo: json['point_no'] as String?,
    subpointNo: json['subpoint_no'] as String?,
    heading: json['heading'] as String?,
    bodyText: json['body_text'] as String,
    normalizedText: json['normalized_text'] as String? ?? '',
    effectiveFrom: json['effective_from'] != null ? DateTime.parse(json['effective_from']) : null,
    effectiveTo: json['effective_to'] != null ? DateTime.parse(json['effective_to']) : null,
    provisionStatus: LegalStatus.fromCode(json['provision_status'] as String? ?? 'active'),
    sourcePage: json['source_page'] as int?,
    sourceNote: json['source_note'] as String?,
    sortPath: json['sort_path'] as String?,
  );
}
