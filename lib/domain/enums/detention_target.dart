enum DetentionTarget {
  vehicle('vehicle', 'Tạm giữ phương tiện'),
  drivingLicense('driving_license', 'Tạm giữ giấy phép lái xe'),
  vehicleRegistration('vehicle_registration', 'Tạm giữ chứng nhận đăng ký xe'),
  inspectionCertificate('inspection_certificate', 'Tạm giữ chứng nhận / tem kiểm định'),
  evidence('evidence', 'Tạm giữ tang vật, phương tiện vi phạm');

  final String code;
  final String label;
  const DetentionTarget(this.code, this.label);

  static DetentionTarget fromCode(String code) {
    return DetentionTarget.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DetentionTarget.vehicle,
    );
  }
}

enum DetentionPurpose {
  prevent('prevent', 'Ngăn chặn ngay hành vi vi phạm (Khoản 1 Điều 48)'),
  ensureExecution('ensure_execution', 'Bảo đảm thi hành quyết định xử phạt (Khoản 2 Điều 48)'),
  verify('verify', 'Xác minh tình tiết làm căn cứ ra quyết định (Khoản 2 Điều 48)');

  final String code;
  final String label;
  const DetentionPurpose(this.code, this.label);

  static DetentionPurpose fromCode(String code) {
    return DetentionPurpose.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DetentionPurpose.prevent,
    );
  }
}
