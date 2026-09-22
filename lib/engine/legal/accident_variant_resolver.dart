import '../../domain/entities/offense.dart';
import '../../domain/enums/vehicle_type.dart';

class AccidentVariantResolver {
  /// Giải quyết trường hợp hành vi vi phạm gây tai nạn giao thông (Điều 6.10, Điều 7.10, Điều 8.8)
  static Offense? resolveAccidentVariant(Offense baseOffense, List<Offense> allOffenses) {
    // 1. Kiểm tra trong relatedOffenses có liên kết accident_variant không
    for (final rel in baseOffense.relatedOffenses) {
      if (rel.relationType == 'accident_variant') {
        try {
          return allOffenses.firstWhere((o) => o.id == rel.toOffenseId || o.offenseCode == rel.toOffenseId);
        } catch (_) {}
      }
    }

    // 2. Tìm theo mã quy tắc chuẩn hóa của Nghị định
    if (baseOffense.vehicleType == VehicleType.car) {
      try {
        return allOffenses.firstWhere((o) => o.offenseCode == 'CAR-006-10-ACCIDENT');
      } catch (_) {}
    } else if (baseOffense.vehicleType == VehicleType.motorcycle || baseOffense.vehicleType == VehicleType.moped) {
      try {
        return allOffenses.firstWhere((o) => o.offenseCode == 'MOTO-007-10-ACCIDENT');
      } catch (_) {}
    }

    return null;
  }
}
