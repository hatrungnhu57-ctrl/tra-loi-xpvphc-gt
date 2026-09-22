import 'package:flutter/material.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../engine/legal/alcohol_calculator.dart';

class AlcoholCalculatorScreen extends StatefulWidget {
  const AlcoholCalculatorScreen({super.key});

  @override
  State<AlcoholCalculatorScreen> createState() => _AlcoholCalculatorScreenState();
}

class _AlcoholCalculatorScreenState extends State<AlcoholCalculatorScreen> {
  final _breathController = TextEditingController(text: '0.32');
  VehicleType _vehicle = VehicleType.motorcycle;
  AlcoholEvaluationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final breath = double.tryParse(_breathController.text);
    setState(() {
      _result = AlcoholCalculator.evaluate(
        breathMgL: breath,
        vehicleType: _vehicle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('TÍNH NỒNG ĐỘ CỒN'),
        backgroundColor: const Color(0xFFFB8C00),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _breathController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Nồng độ cồn khí thở (mg/L)',
                      hintText: 'Ví dụ: 0.25, 0.32, 0.45...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_bar),
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_result != null)
            Card(
              elevation: 2,
              color: const Color(0xFFFFF3E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _result!.level.split(':')[0],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(_result!.legalRef, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(_result!.level, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'Mức phạt: ${_result!.fineMin ~/ 1000000} - ${_result!.fineMax ~/ 1000000} triệu đồng',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFC62828)),
                    ),
                    if (_result!.points != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Trừ điểm GPLX: ${_result!.points} điểm',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                      ),
                    ],
                    if (_result!.suspensionMinMonths != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tước GPLX: ${_result!.suspensionMinMonths?.toInt()} - ${_result!.suspensionMaxMonths?.toInt()} tháng',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
                      ),
                    ],
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
