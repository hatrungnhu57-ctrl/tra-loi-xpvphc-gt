enum PenaltyType {
  fine('fine', 'Phạt tiền'),
  warning('warning', 'Phạt cảnh cáo'),
  licensePoints('license_points', 'Trừ điểm giấy phép lái xe'),
  licenseSuspension('license_suspension', 'Tước quyền sử dụng GPLX'),
  badgeSuspension('badge_suspension', 'Tước quyền sử dụng phù hiệu'),
  inspectionSuspension('inspection_suspension', 'Tước chứng nhận / tem kiểm định'),
  confiscation('confiscation', 'Tịch thu tang vật, phương tiện'),
  activitySuspension('activity_suspension', 'Đình chỉ hoạt động');

  final String code;
  final String label;
  const PenaltyType(this.code, this.label);

  static PenaltyType fromCode(String code) {
    return PenaltyType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PenaltyType.fine,
    );
  }
}
