import 'package:flutter/material.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../engine/legal/speed_calculator.dart';

class SpeedCalculatorScreen extends StatefulWidget {
  const SpeedCalculatorScreen({super.key});

  @override
  State<SpeedCalculatorScreen> createState() => _SpeedCalculatorScreenState();
}

class _SpeedCalculatorScreenState extends State<SpeedCalculatorScreen> {
  final _measuredController = TextEditingController(text: '76');
  final _limitController = TextEditingController(text: '60');
  VehicleType _vehicle = VehicleType.car;
  bool _causedAccident = false;
  SpeedEvaluationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final measured = double.tryParse(_measuredController.text);
    final limit = double.tryParse(_limitController.text);
    if (measured != null && limit != null) {
      setState(() {
        _result = SpeedCalculator.evaluate(
          measuredSpeed: measured,
          speedLimit: limit,
          vehicleType: _vehicle,
          causedAccident: _causedAccident,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('TÍNH TỐC ĐỘ (SPEED PRO)'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input Form Card
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
                      const SizedBox(width: 8),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _measuredController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tốc độ đo được (km/h)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.speed),
                          ),
                          onChanged: (_) => _calculate(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tốc độ tối đa (km/h)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.speed_outlined),
                          ),
                          onChanged: (_) => _calculate(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Có gây tai nạn giao thông?'),
                    value: _causedAccident,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() => _causedAccident = val);
                      _calculate();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Output Result Card
          if (_result != null)
            Card(
              elevation: 2,
              color: const Color(0xFFFFEBEE),
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
                          'Vượt: ${_result!.speedExcess.toStringAsFixed(1)} km/h',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(_result!.legalRef, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      'Khung: ${_result!.speedBracket}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
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
                    const SizedBox(height: 8),
                    Text(_result!.note, style: const TextStyle(fontSize: 13, color: Color(0xFF455A64))),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Vượt dưới 5 km/h không bị xử phạt vi phạm hành chính.',
                  style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
