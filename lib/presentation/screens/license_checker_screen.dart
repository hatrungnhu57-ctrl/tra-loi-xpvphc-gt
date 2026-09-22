import 'package:flutter/material.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../engine/legal/license_checker.dart';

class LicenseCheckerScreen extends StatefulWidget {
  const LicenseCheckerScreen({super.key});

  @override
  State<LicenseCheckerScreen> createState() => _LicenseCheckerScreenState();
}

class _LicenseCheckerScreenState extends State<LicenseCheckerScreen> {
  VehicleType _vehicle = VehicleType.motorcycle;
  double _engineCc = 150;
  bool _hasValidLicense = false;
  bool _expiredUnder1Year = false;
  int? _driverAge;
  LicenseEvaluationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() {
      _result = LicenseChecker.evaluate(
        vehicleType: _vehicle,
        engineCc: _vehicle == VehicleType.motorcycle ? _engineCc : null,
        hasValidLicense: _hasValidLicense,
        licenseExpiredUnder1Year: _expiredUnder1Year,
        driverAge: _driverAge,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('KIỂM TRA GPLX & ĐỘ TUỔI'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn loại phương tiện:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Xe Mô tô / Xe máy')),
                          selected: _vehicle == VehicleType.motorcycle,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _vehicle = VehicleType.motorcycle);
                              _calculate();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Xe Ô tô')),
                          selected: _vehicle == VehicleType.car,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _vehicle = VehicleType.car);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_vehicle == VehicleType.motorcycle) ...[
                    const SizedBox(height: 16),
                    const Text('Dung tích xi-lanh:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Đến 125 cm3 (<=125cc)')),
                            selected: _engineCc <= 125,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _engineCc = 110);
                                _calculate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Trên 125 cm3 (>125cc, ví dụ 150cc)')),
                            selected: _engineCc > 125,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _engineCc = 150);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_result != null)
            Card(
              elevation: 2,
              color: const Color(0xFFE3F2FD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KẾT QUẢ PHÁP LÝ',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(_result!.legalRef, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(_result!.conditionDescription, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      _result!.isWarning
                          ? 'Hình thức phạt: CẢNH CÁO'
                          : 'Mức phạt: ${_result!.fineMin ~/ 1000000} - ${_result!.fineMax ~/ 1000000} triệu đồng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _result!.isWarning ? const Color(0xFFE65100) : const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tạm giữ phương tiện: ${_result!.detentionBasis}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD84315)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
