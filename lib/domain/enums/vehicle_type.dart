enum VehicleType {
  car('car', 'Xe ô tô và các loại xe tương tự'),
  motorcycle('motorcycle', 'Xe mô tô, xe máy'),
  moped('moped', 'Xe gắn máy (kể cả xe máy điện)'),
  specialMachinery('special_machinery', 'Xe máy chuyên dùng'),
  bicycle('bicycle', 'Xe đạp, xe thô sơ'),
  electricBicycle('electric_bicycle', 'Xe đạp máy, xe đạp điện'),
  pedestrian('pedestrian', 'Người đi bộ'),
  animal('animal', 'Người dẫn dắt vật nuôi / xe súc vật kéo'),
  all('all', 'Mọi phương tiện');

  final String code;
  final String label;
  const VehicleType(this.code, this.label);

  static VehicleType fromCode(String code) {
    return VehicleType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => VehicleType.all,
    );
  }
}
