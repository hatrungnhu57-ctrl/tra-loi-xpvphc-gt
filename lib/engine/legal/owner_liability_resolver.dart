import '../../domain/enums/vehicle_type.dart';

class OwnerLiabilityResult {
  final VehicleType vehicleType;
  final String conductDescription;
  final String legalRef;
  final int fineMinIndividual;
  final int fineMaxIndividual;
  final int fineMinOrg;
  final int fineMaxOrg;
  final bool hasDetention;
  final String detentionBasis;
  final String note;

  const OwnerLiabilityResult({
    required this.vehicleType,
    required this.conductDescription,
    required this.legalRef,
    required this.fineMinIndividual,
    required this.fineMaxIndividual,
    required this.fineMinOrg,
    required this.fineMaxOrg,
    this.hasDetention = true,
    this.detentionBasis = 'Khoản 1 Điểm l Điều 48',
    required this.note,
  });
}

class OwnerLiabilityResolver {
  /// Giải quyết trách nhiệm chủ phương tiện giao xe cho người không đủ điều kiện (Điều 32)
  static OwnerLiabilityResult resolveUnqualifiedDriverHandover({
    required VehicleType vehicleType,
  }) {
    if (vehicleType == VehicleType.car || vehicleType == VehicleType.specialMachinery) {
      return const OwnerLiabilityResult(
        vehicleType: VehicleType.car,
        conductDescription: 'Giao xe hoặc để cho người không đủ điều kiện điều khiển xe ô tô tham gia giao thông',
        legalRef: 'Điểm i Khoản 14 Điều 32',
        fineMinIndividual: 28000000,
        fineMaxIndividual: 30000000,
        fineMinOrg: 56000000,
        fineMaxOrg: 60000000,
        note: 'Cá nhân phạt 28 - 30 triệu, tổ chức phạt 56 - 60 triệu; tạm giữ phương tiện (Khoản 1 Điểm l Điều 48)',
      );
    } else {
      // Mô tô / xe gắn máy
      return const OwnerLiabilityResult(
        vehicleType: VehicleType.motorcycle,
        conductDescription: 'Giao xe hoặc để cho người không đủ điều kiện điều khiển xe mô tô, xe gắn máy tham gia giao thông',
        legalRef: 'Khoản 10 Điều 32',
        fineMinIndividual: 8000000,
        fineMaxIndividual: 10000000,
        fineMinOrg: 16000000,
        fineMaxOrg: 20000000,
        note: 'Cá nhân phạt 8 - 10 triệu, tổ chức phạt 16 - 20 triệu; tạm giữ phương tiện (Khoản 1 Điểm l Điều 48)',
      );
    }
  }
}
