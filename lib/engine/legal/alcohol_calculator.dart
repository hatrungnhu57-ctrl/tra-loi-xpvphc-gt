import '../../domain/enums/vehicle_type.dart';

class AlcoholEvaluationResult {
  final double? breathValue;
  final double? bloodValue;
  final VehicleType vehicleType;
  final String level;
  final String legalRef;
  final int fineMin;
  final int fineMax;
  final int? points;
  final double? suspensionMinMonths;
  final double? suspensionMaxMonths;
  final bool hasDetention;
  final String detentionBasis;
  final String note;

  const AlcoholEvaluationResult({
    this.breathValue,
    this.bloodValue,
    required this.vehicleType,
    required this.level,
    required this.legalRef,
    required this.fineMin,
    required this.fineMax,
    this.points,
    this.suspensionMinMonths,
    this.suspensionMaxMonths,
    this.hasDetention = true,
    this.detentionBasis = 'Khoản 1 Điều 48',
    required this.note,
  });
}

class AlcoholCalculator {
  /// Đánh giá nồng độ cồn theo khí thở (mg/L) hoặc máu (mg/100ml)
  static AlcoholEvaluationResult? evaluate({
    double? breathMgL,
    double? bloodMg100ml,
    required VehicleType vehicleType,
  }) {
    if ((breathMgL == null || breathMgL <= 0) && (bloodMg100ml == null || bloodMg100ml <= 0)) {
      return null;
    }

    // Xác định mức cồn (Mức 1, Mức 2, Mức 3)
    // Mức 1: breath <= 0.25 || blood <= 50
    // Mức 2: 0.25 < breath <= 0.40 || 50 < blood <= 80
    // Mức 3: breath > 0.40 || blood > 80
    int level = 1;
    if (breathMgL != null) {
      if (breathMgL > 0.40) {
        level = 3;
      } else if (breathMgL > 0.25) {
        level = 2;
      } else {
        level = 1;
      }
    } else if (bloodMg100ml != null) {
      if (bloodMg100ml > 80.0) {
        level = 3;
      } else if (bloodMg100ml > 50.0) {
        level = 2;
      } else {
        level = 1;
      }
    }

    if (vehicleType == VehicleType.car) {
      switch (level) {
        case 1:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 1: Chưa vượt quá 50 mg/100 ml máu hoặc <= 0,25 mg/1 lít khí thở',
            legalRef: 'Điểm c Khoản 6 Điều 6',
            fineMin: 6000000,
            fineMax: 8000000,
            points: 4,
            note: 'Phạt tiền 6 - 8 triệu, trừ 04 điểm GPLX, tạm giữ xe (Khoản 1 Điều 48)',
          );
        case 2:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 2: Vượt quá 50 - 80 mg/100 ml máu hoặc > 0,25 - 0,40 mg/1 lít khí thở',
            legalRef: 'Điểm a Khoản 9 Điều 6',
            fineMin: 18000000,
            fineMax: 20000000,
            points: 10,
            note: 'Phạt tiền 18 - 20 triệu, trừ 10 điểm GPLX, tạm giữ xe (Khoản 1 Điều 48)',
          );
        case 3:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 3: Vượt quá 80 mg/100 ml máu hoặc > 0,40 mg/1 lít khí thở',
            legalRef: 'Điểm a Khoản 11 & Điểm c Khoản 15 Điều 6',
            fineMin: 30000000,
            fineMax: 40000000,
            points: null,
            suspensionMinMonths: 22,
            suspensionMaxMonths: 24,
            note: 'Phạt tiền 30 - 40 triệu, tước GPLX 22 - 24 tháng, tạm giữ xe (Khoản 1 Điều 48)',
          );
      }
    } else {
      // Mô tô / xe máy
      switch (level) {
        case 1:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 1: Chưa vượt quá 50 mg/100 ml máu hoặc <= 0,25 mg/1 lít khí thở',
            legalRef: 'Điểm a Khoản 6 Điều 7',
            fineMin: 2000000,
            fineMax: 3000000,
            points: 4,
            note: 'Phạt tiền 2 - 3 triệu, trừ 04 điểm GPLX, tạm giữ xe (Khoản 1 Điều 48)',
          );
        case 2:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 2: Vượt quá 50 - 80 mg/100 ml máu hoặc > 0,25 - 0,40 mg/1 lít khí thở',
            legalRef: 'Điểm b Khoản 8 Điều 7',
            fineMin: 6000000,
            fineMax: 8000000,
            points: 10,
            note: 'Phạt tiền 6 - 8 triệu, trừ 10 điểm GPLX, tạm giữ xe (Khoản 1 Điều 48)',
          );
        case 3:
          return AlcoholEvaluationResult(
            breathValue: breathMgL,
            bloodValue: bloodMg100ml,
            vehicleType: vehicleType,
            level: 'Mức 3: Vượt quá 80 mg/100 ml máu hoặc > 0,40 mg/1 lít khí thở',
            legalRef: 'Điểm d Khoản 9 & Điểm c Khoản 12 Điều 7',
            fineMin: 8000000,
            fineMax: 10000000,
            points: null,
            suspensionMinMonths: 22,
            suspensionMaxMonths: 24,
            note: 'Phạt tiền 8 - 10 triệu, tước GPLX 22 - 24 tháng, tạm giữ xe (Khoản 1 Điều 48)',
          );
      }
    }
    return null;
  }
}
