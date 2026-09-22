enum RelationType {
  ownerLiability('owner_liability', 'Trách nhiệm chủ phương tiện tương ứng (Điều 32)'),
  accidentVariant('accident_variant', 'Chuyển biến thể khi gây tai nạn giao thông'),
  documentResolution('document_resolution', 'Quy trình xử lý không xuất trình giấy tờ (Điều 48.3)'),
  sameConduct('same_conduct', 'Cùng hành vi vi phạm'),
  alternative('alternative', 'Hành vi thay thế / lựa chọn'),
  supersedes('supersedes', 'Thay thế quy định cũ'),
  related('related', 'Hành vi liên quan');

  final String code;
  final String label;
  const RelationType(this.code, this.label);

  static RelationType fromCode(String code) {
    return RelationType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => RelationType.related,
    );
  }
}

enum LegalStatus {
  active('active', 'Đang có hiệu lực'),
  future('future', 'Chưa có hiệu lực (Hiệu lực tương lai)'),
  repealed('repealed', 'Đã bị bãi bỏ'),
  superseded('superseded', 'Đã bị sửa đổi, thay thế'),
  needsReview('NEEDS_REVIEW', 'Cần kiểm duyệt đối chiếu nguồn gốc');

  final String code;
  final String label;
  const LegalStatus(this.code, this.label);

  static LegalStatus fromCode(String code) {
    return LegalStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => LegalStatus.active,
    );
  }
}
