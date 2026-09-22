import 'package:flutter/material.dart';
import '../../domain/enums/penalty_type.dart';
import '../../domain/enums/detention_target.dart';

class PenaltyBadge extends StatelessWidget {
  final PenaltyType type;
  final String label;

  const PenaltyBadge({
    super.key,
    required this.type,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (type) {
      case PenaltyType.fine:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        icon = Icons.attach_money;
        break;
      case PenaltyType.warning:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        icon = Icons.warning_amber_rounded;
        break;
      case PenaltyType.licensePoints:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        icon = Icons.credit_card_off_rounded;
        break;
      case PenaltyType.licenseSuspension:
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF6A1B9A);
        icon = Icons.block_rounded;
        break;
      default:
        bg = const Color(0xFFECEFF1);
        fg = const Color(0xFF37474F);
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DetentionBadge extends StatelessWidget {
  final String text;

  const DetentionBadge({super.key, this.text = 'Tạm giữ xe (Đ.48)'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD84315).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.car_crash_outlined, size: 14, color: Color(0xFFD84315)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD84315),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PointsBadge extends StatelessWidget {
  final int points;

  const PointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC62828).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_circle_outline, size: 14, color: Color(0xFFC62828)),
          const SizedBox(width: 4),
          Text(
            'Trừ $points điểm GPLX',
            style: const TextStyle(
              color: Color(0xFFC62828),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
