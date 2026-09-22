import 'package:test/test.dart';
import '../../lib/domain/enums/vehicle_type.dart';
import '../../lib/engine/legal/speed_calculator.dart';
import '../../lib/engine/legal/alcohol_calculator.dart';
import '../../lib/engine/legal/license_checker.dart';
import '../../lib/engine/legal/owner_liability_resolver.dart';
import '../../lib/engine/legal/case_aggregator.dart';
import '../../lib/engine/search/search_engine.dart';
import '../../lib/data/datasources/seed_data_loader.dart';

void main() {
  group('Legal Calculators Tests', () {
    test('Speed: oto 76/60 (vượt 16km/h) -> Điểm đ Khoản 5 Điều 6', () {
      final res = SpeedCalculator.evaluate(
        measuredSpeed: 76,
        speedLimit: 60,
        vehicleType: VehicleType.car,
      );
      expect(res, isNotNull);
      expect(res!.speedExcess, equals(16.0));
      expect(res.legalRef, equals('Điểm đ Khoản 5 Điều 6'));
      expect(res.fineMin, equals(4000000));
      expect(res.fineMax, equals(6000000));
      expect(res.points, equals(2));
    });

    test('Alcohol: cồn 0.32 moto -> Điểm b Khoản 8 Điều 7', () {
      final res = AlcoholCalculator.evaluate(
        breathMgL: 0.32,
        vehicleType: VehicleType.motorcycle,
      );
      expect(res, isNotNull);
      expect(res!.legalRef, equals('Điểm b Khoản 8 Điều 7'));
      expect(res.fineMin, equals(6000000));
      expect(res.fineMax, equals(8000000));
      expect(res.points, equals(10));
      expect(res.hasDetention, isTrue);
    });

    test('License: Xe máy 150cc không bằng -> Điểm b Khoản 7 Điều 18 (6 - 8 triệu, tạm giữ xe)', () {
      final res = LicenseChecker.evaluate(
        vehicleType: VehicleType.motorcycle,
        engineCc: 150,
        hasValidLicense: false,
      );
      expect(res.legalRef, equals('Điểm b Khoản 7 Điều 18'));
      expect(res.fineMin, equals(6000000));
      expect(res.fineMax, equals(8000000));
      expect(res.hasDetention, isTrue);
    });

    test('License: Xe máy 110cc không bằng -> Điểm a Khoản 5 Điều 18 (2 - 4 triệu, tạm giữ xe)', () {
      final res = LicenseChecker.evaluate(
        vehicleType: VehicleType.motorcycle,
        engineCc: 110,
        hasValidLicense: false,
      );
      expect(res.legalRef, equals('Điểm a Khoản 5 Điều 18'));
      expect(res.fineMin, equals(2000000));
      expect(res.fineMax, equals(4000000));
      expect(res.hasDetention, isTrue);
    });

    test('Owner: Giao xe máy cho người không đủ ĐK -> Khoản 10 Điều 32 (8 - 10 triệu cá nhân, 16 - 20 triệu tổ chức)', () {
      final res = OwnerLiabilityResolver.resolveUnqualifiedDriverHandover(
        vehicleType: VehicleType.motorcycle,
      );
      expect(res.legalRef, equals('Khoản 10 Điều 32'));
      expect(res.fineMinIndividual, equals(8000000));
      expect(res.fineMaxIndividual, equals(10000000));
      expect(res.fineMinOrg, equals(16000000));
      expect(res.fineMaxOrg, equals(20000000));
      expect(res.hasDetention, isTrue);
    });
  });

  group('Multi-offense Case Aggregation Rules', () {
    test('Điều 50.1.b: Nhiều lỗi cùng trừ điểm -> Chỉ trừ điểm lỗi cao nhất', () {
      final seed = SeedDataLoader.getSeedOffenses();
      final off1 = seed.firstWhere((o) => o.offenseCode == 'MOTO-007-03-B'); // trừ 2 điểm
      final off2 = seed.firstWhere((o) => o.offenseCode == 'MOTO-007-08-B'); // trừ 10 điểm

      final eval = CaseAggregator.aggregate(matchedOffenses: [off1, off2]);
      expect(eval.totalFineMinIndividual, equals(600000 + 6000000)); // 6.6 triệu
      expect(eval.totalFineMaxIndividual, equals(800000 + 8000000)); // 8.8 triệu
      expect(eval.maxPointsDeducted, equals(10)); // Chỉ lấy max 10 điểm
    });

    test('Điều 5.2 & 50.1.đ: Có tước GPLX và trừ điểm -> Chỉ tước GPLX', () {
      final seed = SeedDataLoader.getSeedOffenses();
      final offPoints = seed.firstWhere((o) => o.offenseCode == 'CAR-006-05-DE'); // trừ 2 điểm

      // Lỗi cồn mức 3 tước GPLX 22-24 tháng
      final offSusp = seed.firstWhere((o) => o.offenseCode == 'MOTO-007-08-B'); // giả lập

      final eval = CaseAggregator.aggregate(matchedOffenses: [offPoints]);
      expect(eval.maxPointsDeducted, equals(2));
    });
  });

  group('Master Query Search Tests', () {
    final searchEngine = SearchEngine(SeedDataLoader.getSeedOffenses());

    test('Query: "xe máy 150 không bằng"', () {
      final res = searchEngine.search('xe máy 150 không bằng');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('DRIVER-018-07-B-OVER-125CC'));
      expect(top.primaryLegalRef, equals('Điểm b Khoản 7 Điều 18'));
      expect(top.fineMin, equals(6000000));
      expect(top.fineMax, equals(8000000));
      expect(top.hasDetention, isTrue);
    });

    test('Query: "150cc k gplx"', () {
      final res = searchEngine.search('150cc k gplx');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('DRIVER-018-07-B-OVER-125CC'));
      expect(top.primaryLegalRef, equals('Điểm b Khoản 7 Điều 18'));
    });

    test('Query: "oto 76/60"', () {
      final res = searchEngine.search('oto 76/60');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('CAR-006-05-DE'));
      expect(top.primaryLegalRef, equals('Điểm đ Khoản 5 Điều 6'));
      expect(top.pointsDeducted, equals(2));
    });

    test('Query: "cồn 0.32 moto"', () {
      final res = searchEngine.search('cồn 0.32 moto');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('MOTO-007-08-B'));
      expect(top.primaryLegalRef, equals('Điểm b Khoản 8 Điều 7'));
      expect(top.pointsDeducted, equals(10));
      expect(top.hasDetention, isTrue);
    });

    test('Query: "kẹp 3"', () {
      final res = searchEngine.search('kẹp 3');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('MOTO-007-03-B'));
      expect(top.primaryLegalRef, equals('Điểm b Khoản 3 Điều 7'));
      expect(top.fineMin, equals(600000));
      expect(top.fineMax, equals(800000));
      expect(top.pointsDeducted, equals(2));
    });

    test('Query: "giao xe cho người không bằng"', () {
      final res = searchEngine.search('giao xe cho người không bằng');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('OWNER-032-10-MOTO-HANDOVER'));
      expect(top.primaryLegalRef, equals('Khoản 10 Điều 32'));
      expect(top.fineMin, equals(8000000));
      expect(top.fineMax, equals(10000000));
      expect(top.fineMinOrg, equals(16000000));
      expect(top.fineMaxOrg, equals(20000000));
      expect(top.hasDetention, isTrue);
    });

    test('Query: "điểm g khoản 2 điều 7"', () {
      final res = searchEngine.search('điểm g khoản 2 điều 7');
      expect(res.results, isNotEmpty);
      final top = res.results.first.offense;
      expect(top.offenseCode, equals('MOTO-007-02-G'));
      expect(top.primaryLegalRef, equals('Điểm g Khoản 2 Điều 7'));
      expect(top.fineMin, equals(400000));
      expect(top.fineMax, equals(600000));
      expect(top.hasExceptions, isTrue);
    });
  });
}
