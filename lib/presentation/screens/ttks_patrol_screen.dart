import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/offense.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../data/datasources/seed_data_loader.dart';
import '../../engine/legal/case_aggregator.dart';
import '../widgets/penalty_badges.dart';
import 'offense_detail_screen.dart';

class TTKSPatrolScreen extends StatefulWidget {
  const TTKSPatrolScreen({super.key});

  @override
  State<TTKSPatrolScreen> createState() => _TTKSPatrolScreenState();
}

class _TTKSPatrolScreenState extends State<TTKSPatrolScreen> {
  VehicleType _selectedVehicle = VehicleType.motorcycle;
  final List<Offense> _allOffenses = SeedDataLoader.getSeedOffenses();
  final Set<String> _selectedOffenseIds = {};

  final TextEditingController _violatorNameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchFilterController = TextEditingController();

  bool _unpresentedDocuments = false;
  String _filterQuery = '';

  @override
  void dispose() {
    _violatorNameController.dispose();
    _plateController.dispose();
    _locationController.dispose();
    _searchFilterController.dispose();
    super.dispose();
  }

  List<Offense> get _filteredOffenses {
    return _allOffenses.where((off) {
      final matchesVehicle = (off.vehicleType == _selectedVehicle || off.vehicleType == VehicleType.all);
      if (!matchesVehicle) return false;

      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      return off.canonicalName.toLowerCase().contains(q) ||
          off.primaryLegalRef.toLowerCase().contains(q) ||
          off.searchText.toLowerCase().contains(q);
    }).toList();
  }

  List<Offense> get _currentSelectedOffenses {
    return _allOffenses.where((o) => _selectedOffenseIds.contains(o.id)).toList();
  }

  IncidentReport _buildIncidentReport() {
    final selected = _currentSelectedOffenses;
    final relatedOwners = <Offense>[];

    for (final off in selected) {
      final ownerId = off.ownerRelatedOffenseId;
      if (ownerId != null) {
        try {
          final ownerOff = _allOffenses.firstWhere((o) => o.id == ownerId || o.offenseCode == ownerId);
          if (!relatedOwners.contains(ownerOff)) relatedOwners.add(ownerOff);
        } catch (_) {}
      }
    }

    final caseEval = CaseAggregator.aggregate(
      matchedOffenses: selected,
      relatedOwnerOffenses: relatedOwners,
    );

    return IncidentReport(
      violatorName: _violatorNameController.text.trim(),
      licensePlate: _plateController.text.trim().toUpperCase(),
      vehicleType: _selectedVehicle,
      location: _locationController.text.trim(),
      incidentTime: DateTime.now(),
      appliedOffenses: selected,
      relatedOwnerOffenses: relatedOwners,
      caseEvaluation: caseEval,
      hasUnpresentedDocuments: _unpresentedDocuments,
    );
  }

  void _showMinutesDialog() {
    final report = _buildIncidentReport();
    final text = report.generateLegalMinutesText();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF0D47A1)),
            SizedBox(width: 8),
            Text('Nội dung Biên bản VPHC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Sao chép'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép nội dung biên bản vào bộ nhớ tạm!'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOffenses = _currentSelectedOffenses;
    final caseEval = CaseAggregator.aggregate(matchedOffenses: selectedOffenses);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('TRỢ LÝ TTKS & LẬP BIÊN BẢN'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          if (selectedOffenses.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, color: Colors.white70),
              label: const Text('Xóa chọn', style: TextStyle(color: Colors.white)),
              onPressed: () => setState(() => _selectedOffenseIds.clear()),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Vehicle Selector & Quick Inputs Tab
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Xe Mô tô / Xe máy')),
                        selected: _selectedVehicle == VehicleType.motorcycle,
                        onSelected: (val) {
                          if (val) setState(() => _selectedVehicle = VehicleType.motorcycle);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Xe Ô tô')),
                        selected: _selectedVehicle == VehicleType.car,
                        onSelected: (val) {
                          if (val) setState(() => _selectedVehicle = VehicleType.car);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _plateController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Biển số (29B1-123.45)',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _violatorNameController,
                        decoration: const InputDecoration(
                          hintText: 'Họ tên người vi phạm',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search filter inside list
                TextField(
                  controller: _searchFilterController,
                  decoration: InputDecoration(
                    hintText: 'Tìm nhanh hành vi vi phạm...',
                    prefixIcon: const Icon(Icons.filter_list, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: (val) => setState(() => _filterQuery = val.trim()),
                ),
              ],
            ),
          ),

          // 2. Offenses Checklist
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _filteredOffenses.length,
              itemBuilder: (ctx, idx) {
                final off = _filteredOffenses[idx];
                final isSelected = _selectedOffenseIds.contains(off.id);
                final fine = off.mainFinePenalty;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  elevation: isSelected ? 2 : 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _selectedOffenseIds.add(off.id);
                        } else {
                          _selectedOffenseIds.remove(off.id);
                        }
                      });
                    },
                    activeColor: const Color(0xFF0D47A1),
                    title: Text(
                      off.canonicalName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              off.primaryLegalRef,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
                            ),
                            const Spacer(),
                            Text(
                              fine?.fineRangeText ?? 'Phạt cảnh cáo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: off.isWarning ? const Color(0xFFE65100) : const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                        if (off.pointsDeducted != null || off.hasDetention) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              if (off.pointsDeducted != null)
                                Text('Trừ ${off.pointsDeducted}đ GPLX', style: const TextStyle(fontSize: 11.5, color: Color(0xFFC62828), fontWeight: FontWeight.w600)),
                              if (off.hasDetention)
                                const Text('• Tạm giữ (Đ.48)', style: TextStyle(fontSize: 11.5, color: Color(0xFFD84315), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Document Workflow Switch (Điều 48.3)
          Container(
            color: const Color(0xFFFFF8E1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Color(0xFFF57F17)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Không xuất trình giấy tờ tại hiện trường (Khoản 3 Điều 48)',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFF57F17)),
                  ),
                ),
                Switch(
                  value: _unpresentedDocuments,
                  activeColor: const Color(0xFFF57F17),
                  onChanged: (val) => setState(() => _unpresentedDocuments = val),
                ),
              ],
            ),
          ),

          // 4. Bottom HUD: Live Summary & Export Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã chọn ${selectedOffenses.length} hành vi:',
                            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            caseEval.individualFineSummary,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC62828)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (caseEval.hasLicenseSuspension)
                            Text(
                              'Tước GPLX: ${caseEval.maxSuspensionMonthsMin?.toInt()}-${caseEval.maxSuspensionMonthsMax?.toInt()} th',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
                            )
                          else if (caseEval.maxPointsDeducted != null)
                            Text(
                              'Trừ: ${caseEval.maxPointsDeducted} điểm (Đ.50)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                            ),
                          if (caseEval.activeDetentions.isNotEmpty)
                            const Text(
                              'Tạm giữ xe (Đ.48)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('XUẤT BIÊN BẢN VI PHẠM (BBVPHC)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: selectedOffenses.isEmpty ? null : _showMinutesDialog,
                    ),
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
