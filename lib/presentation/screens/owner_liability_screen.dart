import 'package:flutter/material.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../engine/legal/owner_liability_resolver.dart';

class OwnerLiabilityScreen extends StatefulWidget {
  const OwnerLiabilityScreen({super.key});

  @override
  State<OwnerLiabilityScreen> createState() => _OwnerLiabilityScreenState();
}

class _OwnerLiabilityScreenState extends State<OwnerLiabilityScreen> {
  VehicleType _vehicle = VehicleType.motorcycle;
  OwnerLiabilityResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() {
      _result = OwnerLiabilityResolver.resolveUnqualifiedDriverHandover(
        vehicleType: _vehicle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('TRÁCH NHIỆM CHỦ XE (ĐIỀU 32)'),
        backgroundColor: const Color(0xFF43A047),
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
                  const Text('Chọn loại phương tiện được giao:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_result != null)
            Card(
              elevation: 2,
              color: const Color(0xFFE8F5E9),
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
                          'HÀNH VI GIAO XE (ĐIỀU 32)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(_result!.legalRef, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(_result!.conductDescription, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(
                      'Chủ xe Cá nhân: ${_result!.fineMinIndividual ~/ 1000000} - ${_result!.fineMaxIndividual ~/ 1000000} triệu đồng',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC62828)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Chủ xe Tổ chức: ${_result!.fineMinOrg ~/ 1000000} - ${_result!.fineMaxOrg ~/ 1000000} triệu đồng',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 12),
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
