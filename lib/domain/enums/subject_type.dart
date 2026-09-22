enum SubjectType {
  driver('driver', 'Người điều khiển phương tiện'),
  ownerIndividual('owner_individual', 'Chủ phương tiện là cá nhân'),
  ownerOrganization('owner_organization', 'Chủ phương tiện là tổ chức'),
  passenger('passenger', 'Người được chở trên xe'),
  pedestrian('pedestrian', 'Người đi bộ'),
  herdsman('herdsman', 'Người điều khiển, dẫn dắt vật nuôi'),
  all('all', 'Tất cả đối tượng');

  final String code;
  final String label;
  const SubjectType(this.code, this.label);

  static SubjectType fromCode(String code) {
    return SubjectType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => SubjectType.driver,
    );
  }
}
