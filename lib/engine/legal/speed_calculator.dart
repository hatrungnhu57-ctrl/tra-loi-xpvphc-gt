import '../../domain/enums/vehicle_type.dart';

class SpeedEvaluationResult {
  final double measuredSpeed;
  final double speedLimit;
  final double speedExcess;
  final VehicleType vehicleType;
  final String speedBracket;
  final String legalRef;
  final int fineMin;
  final int fineMax;
  final int? points;
  final double? suspensionMinMonths;
  final double? suspensionMaxMonths;
  final bool hasDetention;
  final String note;

  const SpeedEvaluationResult({
    required this.measuredSpeed,
    required this.speedLimit,
    required this.speedExcess,
    required this.vehicleType,
    required this.speedBracket,
    required this.legalRef,
    required this.fineMin,
    required this.fineMax,
    this.points,
    this.suspensionMinMonths,
    this.suspensionMaxMonths,
    this.hasDetention = false,
    required this.note,
  });
}

class SpeedCalculator {
  /// Tính toán mức xử phạt theo tốc độ đo được và tốc độ giới hạn
  static SpeedEvaluationResult? evaluate({
    required double measuredSpeed,
    required double speedLimit,
    required VehicleType vehicleType,
    bool causedAccident = false,
  }) {
    final excess = measuredSpeed - speedLimit;
    if (excess < 5.0) {
      // Vượt dưới 5 km/h không bị xử phạt vi phạm hành chính
      return null;
    }

    if (vehicleType == VehicleType.car) {
      if (causedAccident) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Chạy quá tốc độ quy định gây tai nạn giao thông',
          legalRef: 'Điểm a Khoản 10 Điều 6',
          fineMin: 20000000,
          fineMax: 22000000,
          points: 10,
          note: 'Chạy quá tốc độ quy định gây tai nạn giao thông',
        );
      }

      if (excess >= 5.0 && excess < 10.0) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Từ 05 km/h đến dưới 10 km/h',
          legalRef: 'Điểm a Khoản 3 Điều 6',
          fineMin: 800000,
          fineMax: 1000000,
          points: null,
          note: 'Phạt tiền từ 800.000 đ đến 1.000.000 đ',
        );
      } else if (excess >= 10.0 && excess <= 20.0) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Từ 10 km/h đến 20 km/h',
          legalRef: 'Điểm đ Khoản 5 Điều 6',
          fineMin: 4000000,
          fineMax: 6000000,
          points: 2,
          note: 'Phạt tiền 4 - 6 triệu, trừ 02 điểm GPLX',
        );
      } else if (excess > 20.0 && excess <= 35.0) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Trên 20 km/h đến 35 km/h',
          legalRef: 'Điểm a Khoản 6 Điều 6',
          fineMin: 6000000,
          fineMax: 8000000,
          points: 4,
          note: 'Phạt tiền 6 - 8 triệu, trừ 04 điểm GPLX',
        );
      } else {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Trên 35 km/h',
          legalRef: 'Điểm a Khoản 7 Điều 6',
          fineMin: 12000000,
          fineMax: 14000000,
          points: 6,
          note: 'Phạt tiền 12 - 14 triệu, trừ 06 điểm GPLX',
        );
      }
    } else {
      // Mô tô / xe máy
      if (causedAccident) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Chạy quá tốc độ quy định gây tai nạn giao thông',
          legalRef: 'Điểm a Khoản 10 Điều 7',
          fineMin: 10000000,
          fineMax: 14000000,
          points: 10,
          note: 'Chạy quá tốc độ quy định gây tai nạn giao thông',
        );
      }

      if (excess >= 5.0 && excess < 10.0) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Từ 05 km/h đến dưới 10 km/h',
          legalRef: 'Điểm b Khoản 2 Điều 7',
          fineMin: 400000,
          fineMax: 600000,
          points: null,
          note: 'Phạt tiền từ 400.000 đ đến 600.000 đ',
        );
      } else if (excess >= 10.0 && excess <= 20.0) {
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Từ 10 km/h đến 20 km/h',
          legalRef: 'Điểm a Khoản 4 Điều 7',
          fineMin: 800000,
          fineMax: 1000000,
          points: null,
          note: 'Phạt tiền từ 800.000 đ đến 1.000.000 đ',
        );
      } else {
        // Trên 20 km/h
        return SpeedEvaluationResult(
          measuredSpeed: measuredSpeed,
          speedLimit: speedLimit,
          speedExcess: excess,
          vehicleType: vehicleType,
          speedBracket: 'Trên 20 km/h',
          legalRef: 'Điểm a Khoản 8 Điều 7',
          fineMin: 6000000,
          fineMax: 8000000,
          points: 4,
          note: 'Phạt tiền 6 - 8 triệu, trừ 04 điểm GPLX',
        );
      }
    }
  }
}
