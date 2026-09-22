import '../../domain/entities/offense.dart';
import '../../domain/entities/provision.dart';

class TemporalResolver {
  /// Kiểm tra một quy định/hành vi có hiệu lực tại thời điểm tra cứu hay không
  static bool isEffective({
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    required DateTime lookupDate,
  }) {
    if (effectiveFrom != null && lookupDate.isBefore(effectiveFrom)) {
      return false; // Chưa có hiệu lực
    }
    if (effectiveTo != null && lookupDate.isAfter(effectiveTo)) {
      return false; // Đã hết hiệu lực / bị thay thế
    }
    return true;
  }

  /// Lọc danh sách hành vi theo ngày xảy ra / tra cứu
  static List<Offense> filterEffectiveOffenses(List<Offense> offenses, DateTime lookupDate) {
    return offenses.where((o) => isEffective(
      effectiveFrom: o.effectiveFrom,
      effectiveTo: o.effectiveTo,
      lookupDate: lookupDate,
    )).toList();
  }

  /// Lọc danh sách điều khoản theo ngày xảy ra / tra cứu
  static List<Provision> filterEffectiveProvisions(List<Provision> provisions, DateTime lookupDate) {
    return provisions.where((p) => isEffective(
      effectiveFrom: p.effectiveFrom,
      effectiveTo: p.effectiveTo,
      lookupDate: lookupDate,
    )).toList();
  }
}
