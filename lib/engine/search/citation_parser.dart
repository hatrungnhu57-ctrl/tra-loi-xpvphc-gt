import '../../domain/entities/search_query_intent.dart';
import '../../core/utils/text_normalizer.dart';

class CitationParser {
  /// Phân tích chuỗi tìm kiếm để nhận diện Điều, Khoản, Điểm
  static LegalCitation? parse(String input) {
    if (input.trim().isEmpty) return null;
    final rawTrimmed = input.trim().toLowerCase();
    final rawUnaccented = TextNormalizer.removeDiacritics(rawTrimmed);

    // Pattern Dot Shorthand trực tiếp từ chuỗi gốc: "g.2.7", "g.2.7", "2.7"
    final pDot = RegExp(r'^([a-zđ])\.([0-9]+[a-z]?)\.([0-9]+)$', caseSensitive: false);
    final mDot = pDot.firstMatch(rawUnaccented);
    if (mDot != null) {
      return LegalCitation(
        pointNo: mDot.group(1)?.toLowerCase(),
        clauseNo: mDot.group(2)?.toLowerCase(),
        articleNo: int.tryParse(mDot.group(3) ?? ''),
      );
    }

    final normalized = TextNormalizer.normalize(input);
    final unaccented = TextNormalizer.removeDiacritics(normalized);

    // Pattern: "g 2 7" (point clause article)
    final pSpace = RegExp(r'^([a-zđ])\s+([0-9]+[a-z]?)\s+([0-9]+)$', caseSensitive: false);
    final mSpace = pSpace.firstMatch(unaccented);
    if (mSpace != null) {
      return LegalCitation(
        pointNo: mSpace.group(1)?.toLowerCase(),
        clauseNo: mSpace.group(2)?.toLowerCase(),
        articleNo: int.tryParse(mSpace.group(3) ?? ''),
      );
    }

    // Pattern 1: "điểm g khoản 2 điều 7" / "diem g khoan 2 dieu 7"
    final p1 = RegExp(
      r'diem\s+([a-zđ])\s+khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)',
      caseSensitive: false,
    );
    final m1 = p1.firstMatch(unaccented);
    if (m1 != null) {
      return LegalCitation(
        pointNo: m1.group(1)?.toLowerCase(),
        clauseNo: m1.group(2)?.toLowerCase(),
        articleNo: int.tryParse(m1.group(3) ?? ''),
      );
    }

    // Pattern 2: "khoản 2 điều 7 điểm g" / "khoan 2 dieu 7 diem g"
    final p2 = RegExp(
      r'khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)\s+diem\s+([a-zđ])',
      caseSensitive: false,
    );
    final m2 = p2.firstMatch(unaccented);
    if (m2 != null) {
      return LegalCitation(
        clauseNo: m2.group(1)?.toLowerCase(),
        articleNo: int.tryParse(m2.group(2) ?? ''),
        pointNo: m2.group(3)?.toLowerCase(),
      );
    }

    // Pattern 3: "điều 7 khoản 2 điểm g" / "dieu 7 khoan 2 diem g"
    final p3 = RegExp(
      r'dieu\s+([0-9]+)\s+khoan\s+([0-9]+[a-z]?)\s+diem\s+([a-zđ])',
      caseSensitive: false,
    );
    final m3 = p3.firstMatch(unaccented);
    if (m3 != null) {
      return LegalCitation(
        articleNo: int.tryParse(m3.group(1) ?? ''),
        clauseNo: m3.group(2)?.toLowerCase(),
        pointNo: m3.group(3)?.toLowerCase(),
      );
    }

    // Pattern 4: "điều 32 khoản 7" / "dieu 32 khoan 7"
    final p4 = RegExp(
      r'dieu\s+([0-9]+)\s+khoan\s+([0-9]+[a-z]?)',
      caseSensitive: false,
    );
    final m4 = p4.firstMatch(unaccented);
    if (m4 != null) {
      return LegalCitation(
        articleNo: int.tryParse(m4.group(1) ?? ''),
        clauseNo: m4.group(2)?.toLowerCase(),
      );
    }

    // Pattern 5: "khoản 2 điều 7" / "khoan 2 dieu 7"
    final p5 = RegExp(
      r'khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)',
      caseSensitive: false,
    );
    final m5 = p5.firstMatch(unaccented);
    if (m5 != null) {
      return LegalCitation(
        clauseNo: m5.group(1)?.toLowerCase(),
        articleNo: int.tryParse(m5.group(2) ?? ''),
      );
    }

    // Pattern 6: Shorthand "k2 d7 g", "k2 d7", "k.2 d.7"
    final p6 = RegExp(
      r'k\.?\s*([0-9]+[a-z]?)\s*d\.?\s*([0-9]+)(?:\s*([a-zđ]))?',
      caseSensitive: false,
    );
    final m6 = p6.firstMatch(unaccented);
    if (m6 != null) {
      return LegalCitation(
        clauseNo: m6.group(1)?.toLowerCase(),
        articleNo: int.tryParse(m6.group(2) ?? ''),
        pointNo: m6.group(3)?.toLowerCase(),
      );
    }

    // Pattern 7: Dot shorthand "g.2.7" (point.clause.article)
    final p7 = RegExp(
      r'^([a-zđ])\.([0-9]+[a-z]?)\.([0-9]+)$',
      caseSensitive: false,
    );
    final m7 = p7.firstMatch(unaccented.trim());
    if (m7 != null) {
      return LegalCitation(
        pointNo: m7.group(1)?.toLowerCase(),
        clauseNo: m7.group(2)?.toLowerCase(),
        articleNo: int.tryParse(m7.group(3) ?? ''),
      );
    }

    // Pattern 8: Single "điều 6" / "dieu 6"
    final p8 = RegExp(
      r'dieu\s+([0-9]+)',
      caseSensitive: false,
    );
    final m8 = p8.firstMatch(unaccented);
    if (m8 != null) {
      return LegalCitation(
        articleNo: int.tryParse(m8.group(1) ?? ''),
      );
    }

    return null;
  }
}
