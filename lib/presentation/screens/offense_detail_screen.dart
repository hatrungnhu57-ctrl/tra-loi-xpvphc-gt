import 'package:flutter/material.dart';
import '../../domain/entities/offense.dart';
import '../widgets/penalty_badges.dart';

class OffenseDetailScreen extends StatelessWidget {
  final Offense offense;

  const OffenseDetailScreen({super.key, required this.offense});

  @override
  Widget build(BuildContext context) {
    final finePenalty = offense.mainFinePenalty;
    final points = offense.pointsDeducted;
    final suspension = offense.suspensionPenalty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(offense.primaryLegalRef),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offense.vehicleType.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                      Text(
                        'Mã: ${offense.offenseCode}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offense.canonicalName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  if (finePenalty != null)
                    Text(
                      finePenalty.fineRangeText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: offense.isWarning ? const Color(0xFFE65100) : const Color(0xFFC62828),
                      ),
                    ),
                  if (offense.fineMinOrg != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tổ chức: ${finePenalty?.orgFineRangeText}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF388E3C)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section 1: Chi tiết hành vi
          _buildSection(
            title: '1. Nội dung quy định hành vi',
            icon: Icons.description_outlined,
            child: Text(
              offense.description,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF263238)),
            ),
          ),

          // Section 2: Trừ điểm GPLX
          if (points != null)
            _buildSection(
              title: '2. Trừ điểm giấy phép lái xe',
              icon: Icons.credit_card_off_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PointsBadge(points: points),
                  const SizedBox(height: 6),
                  const Text(
                    'Điểm bị trừ được cập nhật vào Cơ sở dữ liệu về TTATGT đường bộ. Nếu trong 12 tháng không bị trừ điểm thì được phục hồi đủ 12 điểm (Điều 50 & 51).',
                    style: TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
                  ),
                ],
              ),
            ),

          // Section 3: Tước GPLX
          if (suspension != null)
            _buildSection(
              title: '3. Tước quyền sử dụng GPLX',
              icon: Icons.block_flipped,
              child: Text(
                'Tước quyền sử dụng giấy phép lái xe từ ${suspension.suspensionMinMonths?.toInt()} tháng đến ${suspension.suspensionMaxMonths?.toInt()} tháng.',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6A1B9A)),
              ),
            ),

          // Section 4: Tạm giữ phương tiện, giấy tờ (Điều 48)
          if (offense.hasDetention)
            _buildSection(
              title: '4. Tạm giữ phương tiện / giấy tờ (Điều 48)',
              icon: Icons.car_crash_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: offense.detentionRules.map((det) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFFD84315)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${det.detentionTarget.label} theo ${det.legalBasisText}: ${det.note ?? ""}',
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFFD84315), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Section 5: Biện pháp khắc phục hậu quả
          if (offense.hasRemedialMeasures)
            _buildSection(
              title: '5. Biện pháp khắc phục hậu quả',
              icon: Icons.build_circle_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: offense.remedialMeasures.map((rem) {
                  return Text('• ${rem.description} (${rem.legalBasisText})', style: const TextStyle(fontSize: 13.5));
                }).toList(),
              ),
            ),

          // Section 6: Ngoại lệ
          if (offense.hasExceptions)
            _buildSection(
              title: '6. Trường hợp ngoại lệ không xử phạt',
              icon: Icons.verified_user_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: offense.exceptions.map((exc) {
                  return Text('• ${exc.description}', style: const TextStyle(fontSize: 13.5, color: Color(0xFF2E7D32)));
                }).toList(),
              ),
            ),

          // Section 7: Trách nhiệm chủ xe liên quan (Điều 32)
          if (offense.relatedOffenses.any((r) => r.relationType == 'owner_liability'))
            _buildSection(
              title: '7. Trách nhiệm chủ phương tiện liên quan (Điều 32)',
              icon: Icons.supervisor_account_outlined,
              child: Text(
                offense.relatedOffenses.firstWhere((r) => r.relationType == 'owner_liability').description,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
              ),
            ),

          // Section 8: Trường hợp gây TNGT
          if (offense.relatedOffenses.any((r) => r.relationType == 'accident_variant'))
            _buildSection(
              title: '8. Trường hợp gây tai nạn giao thông',
              icon: Icons.warning_amber_rounded,
              child: Text(
                offense.relatedOffenses.firstWhere((r) => r.relationType == 'accident_variant').description,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFFC62828), fontWeight: FontWeight.w600),
              ),
            ),

          // Section 9: Căn cứ pháp lý & Nguồn văn bản
          _buildSection(
            title: '9. Căn cứ pháp lý gốc',
            icon: Icons.menu_book_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Căn cứ: ${offense.primaryLegalRef}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Văn bản: ${offense.legalDocumentTitle ?? offense.legalDocumentNumber}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
                ),
                if (offense.sourceNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ghi chú sửa đổi: ${offense.sourceNote}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF00838F), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
