import '../../domain/enums/vehicle_type.dart';

class LicenseEvaluationResult {
  final VehicleType vehicleType;
  final double? engineCapacityCc;
  final String conditionDescription;
  final String legalRef;
  final int fineMin;
  final int fineMax;
  final bool isWarning;
  final int? points;
  final bool hasDetention;
  final String detentionBasis;
  final String note;

  const LicenseEvaluationResult({
    required this.vehicleType,
    this.engineCapacityCc,
    required this.conditionDescription,
    required this.legalRef,
    required this.fineMin,
    required this.fineMax,
    this.isWarning = false,
    this.points,
    this.hasDetention = true,
    this.detentionBasis = 'Khoản 1 Điểm i Điều 48',
    required this.note,
  });
}

class LicenseChecker {
  /// Đánh giá tình trạng GPLX theo loại xe và dung tích xi lanh
  static LicenseEvaluationResult evaluate({
    required VehicleType vehicleType,
    double? engineCc,
    double? powerKw,
    required bool hasValidLicense,
    bool licenseExpiredUnder1Year = false,
    bool licenseExpiredOver1Year = false,
    bool licenseInappropriateCategory = false,
    int? driverAge,
  }) {
    // Kiểm tra độ tuổi người lái nếu có
    if (driverAge != null) {
      if (driverAge >= 14 && driverAge < 16) {
        return const LicenseEvaluationResult(
          vehicleType: VehicleType.all,
          conditionDescription: 'Người từ đủ 14 tuổi đến dưới 16 tuổi điều khiển xe',
          legalRef: 'Khoản 1 Điều 18',
          fineMin: 0,
          fineMax: 0,
          isWarning: true,
          note: 'Phạt cảnh cáo, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
        );
      } else if (driverAge >= 16 && driverAge < 18) {
        if (vehicleType == VehicleType.car) {
          return const LicenseEvaluationResult(
            vehicleType: VehicleType.car,
            conditionDescription: 'Người từ đủ 16 tuổi đến dưới 18 tuổi điều khiển xe ô tô',
            legalRef: 'Khoản 6 Điều 18',
            fineMin: 4000000,
            fineMax: 6000000,
            note: 'Phạt tiền 4 - 6 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          );
        } else {
          return const LicenseEvaluationResult(
            vehicleType: VehicleType.motorcycle,
            conditionDescription: 'Người từ đủ 16 tuổi đến dưới 18 tuổi điều khiển xe mô tô',
            legalRef: 'Điểm a Khoản 4 Điều 18',
            fineMin: 400000,
            fineMax: 600000,
            note: 'Phạt tiền từ 400.000 đ đến 600.000 đ, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          );
        }
      }
    }

    if (vehicleType == VehicleType.car) {
      if (licenseExpiredUnder1Year) {
        return const LicenseEvaluationResult(
          vehicleType: VehicleType.car,
          conditionDescription: 'Có GPLX ô tô nhưng đã hết hạn sử dụng dưới 01 năm',
          legalRef: 'Điểm a Khoản 8 Điều 18',
          fineMin: 8000000,
          fineMax: 10000000,
          note: 'Phạt tiền 8 - 10 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
        );
      }
      if (licenseExpiredOver1Year || licenseInappropriateCategory) {
        return const LicenseEvaluationResult(
          vehicleType: VehicleType.car,
          conditionDescription: 'GPLX ô tô không phù hợp hoặc hết hạn từ 01 năm trở lên',
          legalRef: 'Điểm a Khoản 9 Điều 18',
          fineMin: 18000000,
          fineMax: 20000000,
          note: 'Phạt tiền 18 - 20 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
        );
      }
      // Không có GPLX
      return const LicenseEvaluationResult(
        vehicleType: VehicleType.car,
        conditionDescription: 'Không có giấy phép lái xe ô tô',
        legalRef: 'Điểm b Khoản 9 Điều 18',
        fineMin: 18000000,
        fineMax: 20000000,
        note: 'Phạt tiền 18 - 20 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
      );
    } else {
      // Mô tô / xe máy
      final isOver125cc = (engineCc != null && engineCc > 125) || (powerKw != null && powerKw > 11);

      if (isOver125cc) {
        if (licenseInappropriateCategory) {
          return LicenseEvaluationResult(
            vehicleType: VehicleType.motorcycle,
            engineCapacityCc: engineCc,
            conditionDescription: 'Có GPLX nhưng không phù hợp loại xe mô tô trên 125cm3',
            legalRef: 'Điểm a Khoản 7 Điều 18',
            fineMin: 6000000,
            fineMax: 8000000,
            note: 'Phạt tiền 6 - 8 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          );
        }
        return LicenseEvaluationResult(
          vehicleType: VehicleType.motorcycle,
          engineCapacityCc: engineCc,
          conditionDescription: 'Không có GPLX điều khiển xe mô tô có dung tích xi lanh trên 125 cm3 (>125cc)',
          legalRef: 'Điểm b Khoản 7 Điều 18',
          fineMin: 6000000,
          fineMax: 8000000,
          note: 'Phạt tiền 6 - 8 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
        );
      } else {
        return LicenseEvaluationResult(
          vehicleType: VehicleType.motorcycle,
          engineCapacityCc: engineCc,
          conditionDescription: 'Không có GPLX điều khiển xe mô tô có dung tích xi lanh đến 125 cm3 (<=125cc)',
          legalRef: 'Điểm a Khoản 5 Điều 18',
          fineMin: 2000000,
          fineMax: 4000000,
          note: 'Phạt tiền 2 - 4 triệu, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
        );
      }
    }
  }
}
