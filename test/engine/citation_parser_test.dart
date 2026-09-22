import 'package:test/test.dart';
import '../../lib/domain/entities/search_query_intent.dart';
import '../../lib/engine/search/citation_parser.dart';

void main() {
  group('CitationParser Tests', () {
    test('Parse "điểm g khoản 2 điều 7"', () {
      final res = CitationParser.parse('điểm g khoản 2 điều 7');
      expect(res, isNotNull);
      expect(res!.pointNo, equals('g'));
      expect(res.clauseNo, equals('2'));
      expect(res.articleNo, equals(7));
    });

    test('Parse shorthand "g.2.7"', () {
      final res = CitationParser.parse('g.2.7');
      expect(res, isNotNull);
      expect(res!.pointNo, equals('g'));
      expect(res.clauseNo, equals('2'));
      expect(res.articleNo, equals(7));
    });

    test('Parse shorthand "k2 d7 g"', () {
      final res = CitationParser.parse('k2 d7 g');
      expect(res, isNotNull);
      expect(res!.clauseNo, equals('2'));
      expect(res.articleNo, equals(7));
      expect(res.pointNo, equals('g'));
    });

    test('Parse "điều 32 khoản 7"', () {
      final res = CitationParser.parse('điều 32 khoản 7');
      expect(res, isNotNull);
      expect(res!.articleNo, equals(32));
      expect(res.clauseNo, equals('7'));
      expect(res.pointNo, isNull);
    });

    test('Parse "khoản 1a điều 6"', () {
      final res = CitationParser.parse('khoản 1a điều 6');
      expect(res, isNotNull);
      expect(res!.articleNo, equals(6));
      expect(res.clauseNo, equals('1a'));
    });
  });
}
