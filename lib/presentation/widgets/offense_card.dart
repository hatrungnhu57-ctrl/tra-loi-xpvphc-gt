import 'package:flutter/material.dart';
import '../../domain/entities/offense.dart';
import '../../domain/enums/vehicle_type.dart';
import 'penalty_badges.dart';

class OffenseCard extends StatelessWidget {
  final Offense offense;
  final VoidCallback? onTap;

  const OffenseCard({
    super.key,
    required this.offense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final finePenalty = offense.mainFinePenalty;
    final fineText = finePenalty?.fineRangeText ?? '';
    final points = offense.pointsDeducted;
    final hasDetention = offense.hasDetention;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Loại xe & Căn cứ pháp lý
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offense.vehicleType.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  Text(
                    offense.primaryLegalRef,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tên hành vi chuẩn hóa
              Text(
                offense.canonicalName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // Khung tiền phạt
              if (fineText.isNotEmpty)
                Text(
                  fineText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: offense.isWarning ? const Color(0xFFE65100) : const Color(0xFFC62828),
                  ),
                ),
              if (offense.fineMinOrg != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tổ chức: ${offense.mainFinePenalty?.orgFineRangeText}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Badges: Điểm, Tạm giữ, Ngoại lệ
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (points != null) PointsBadge(points: points),
                  if (hasDetention) const DetentionBadge(),
                  if (offense.hasExceptions)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Có ngoại lệ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF512DA8),
                        ),
                      ),
                    ),
                  if (offense.sourceNote != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Sửa bởi NĐ 238',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00838F),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
