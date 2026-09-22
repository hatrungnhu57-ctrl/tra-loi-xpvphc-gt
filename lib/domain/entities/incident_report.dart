import '../entities/offense.dart';
import '../entities/case_evaluation.dart';
import '../entities/detention_rule.dart';
import '../enums/vehicle_type.dart';

class IncidentReport {
  final String? violatorName;
  final String? violatorDob;
  final String? violatorIdNumber; // CCCD
  final String? licensePlate;
  final VehicleType vehicleType;
  final String? location;
  final DateTime incidentTime;

  final List<Offense> appliedOffenses;
  final List<Offense> relatedOwnerOffenses;
  final CaseEvaluation caseEvaluation;
  final List<String> seizedItems; // Tang vật, giấy tờ, phương tiện tạm giữ
  final bool hasUnpresentedDocuments; // Không xuất trình giấy tờ tại thời điểm kiểm tra (Điều 48.3)
  final String? officerNotes;

  const IncidentReport({
    this.violatorName,
    this.violatorDob,
    this.violatorIdNumber,
    this.licensePlate,
    required this.vehicleType,
    this.location,
    required this.incidentTime,
    required this.appliedOffenses,
    this.relatedOwnerOffenses = const [],
    required this.caseEvaluation,
    this.seizedItems = const [],
    this.hasUnpresentedDocuments = false,
    this.officerNotes,
  });

  /// Tạo văn bản trích xuất tiêu chuẩn cho Biên bản Vi phạm Hành chính (BBVPHC)
  String generateLegalMinutesText() {
    final buffer = StringBuffer();
    buffer.writeln('=== TÓM TẮT HÀNH VI & CĂN CỨ XỬ PHẠT (TTKS) ===');
    buffer.writeln('Thời gian: ${incidentTime.hour.toString().padLeft(2, '0')}:${incidentTime.minute.toString().padLeft(2, '0')} ngày ${incidentTime.day}/${incidentTime.month}/${incidentTime.year}');
    if (location != null && location!.isNotEmpty) {
      buffer.writeln('Địa điểm: $location');
    }
    if (licensePlate != null && licensePlate!.isNotEmpty) {
      buffer.writeln('Phương tiện: ${vehicleType.label} - Biển kiểm soát: $licensePlate');
    } else {
      buffer.writeln('Phương tiện: ${vehicleType.label}');
    }
    if (violatorName != null && violatorName!.isNotEmpty) {
      buffer.writeln('Người vi phạm: $violatorName ${violatorDob != null ? "($violatorDob)" : ""} - CCCD: ${violatorIdNumber ?? "..."}');
    }
    buffer.writeln('--------------------------------------------------');

    buffer.writeln('I. CÁC HÀNH VI VI PHẠM HÀNH CHÍNH:');
    for (int i = 0; i < appliedOffenses.length; i++) {
      final off = appliedOffenses[i];
      buffer.writeln('${i + 1}. ${off.canonicalName}');
      buffer.writeln('   - Căn cứ pháp lý: ${off.primaryLegalRef} ${off.legalDocumentNumber}');
      buffer.writeln('   - Khung phạt tiền: ${off.mainFinePenalty?.fineRangeText ?? "Phạt cảnh cáo"}');
      if (off.pointsDeducted != null) {
        buffer.writeln('   - Mức trừ điểm GPLX theo quy định: ${off.pointsDeducted} điểm');
      }
      if (off.suspensionPenalty != null) {
        buffer.writeln('   - Hình thức phạt bổ sung: Tước GPLX ${off.suspensionPenalty!.suspensionMinMonths?.toInt()} - ${off.suspensionPenalty!.suspensionMaxMonths?.toInt()} tháng');
      }
    }

    buffer.writeln('\nII. KẾT QUẢ ÁP DỤNG QUY TẮC PHÁP LÝ TỔNG HỢP:');
    buffer.writeln('1. Tổng mức phạt tiền người điều khiển:');
    buffer.writeln('   ${caseEvaluation.individualFineSummary}');

    if (caseEvaluation.hasLicenseSuspension) {
      buffer.writeln('2. Hình thức phạt bổ sung:');
      buffer.writeln('   Tước quyền sử dụng GPLX từ ${caseEvaluation.maxSuspensionMonthsMin?.toInt()} đến ${caseEvaluation.maxSuspensionMonthsMax?.toInt()} tháng (${caseEvaluation.suspensionLegalBasis})');
      buffer.writeln('   * Lưu ý: Áp dụng Khoản 2 Điều 5 & Điểm đ Khoản 1 Điều 50, do có hành vi bị tước GPLX nên KHÔNG trừ điểm GPLX đối với các hành vi còn lại.');
    } else if (caseEvaluation.maxPointsDeducted != null) {
      buffer.writeln('2. Trừ điểm giấy phép lái xe:');
      buffer.writeln('   Tổng điểm trừ: ${caseEvaluation.maxPointsDeducted} điểm (Áp dụng Điểm b Khoản 1 Điều 50: Chỉ trừ điểm đối với hành vi bị trừ nhiều điểm nhất theo ${caseEvaluation.pointsDeductedLegalBasis})');
    } else {
      buffer.writeln('2. Trừ điểm GPLX: Không áp dụng');
    }

    if (caseEvaluation.activeDetentions.isNotEmpty || seizedItems.isNotEmpty) {
      buffer.writeln('\nIII. BIỆN PHÁP NGĂN CHẶN / TẠM GIỮ (ĐIỀU 48):');
      final uniqueDetentions = caseEvaluation.activeDetentions.map((d) => '${d.detentionTarget.label} (${d.legalBasisText})').toSet();
      for (final det in uniqueDetentions) {
        buffer.writeln('• Tạm giữ: $det');
      }
      if (seizedItems.isNotEmpty) {
        buffer.writeln('• Tang vật/giấy tờ tạm giữ thực tế: ${seizedItems.join(", ")}');
      }
    }

    if (hasUnpresentedDocuments) {
      buffer.writeln('\nIV. QUY TRÌNH KHÔNG XUẤT TRÌNH GIẤY TỜ TẠI HIỆN TRƯỜNG (KHOẢN 3 ĐIỀU 48):');
      buffer.writeln('• Lập biên bản người điều khiển về hành vi không có giấy tờ.');
      buffer.writeln('• Đồng thời lập biên bản chủ phương tiện theo quy định tương ứng tại Điều 32 và tạm giữ phương tiện.');
      buffer.writeln('• Hẹn thời hạn đến giải quyết: Nếu trong thời hạn hẹn xuất trình được GPLX/Đăng ký hợp lệ thì không xử phạt hành vi không có giấy tờ và không xử phạt chủ phương tiện (Điểm c Khoản 3 Điều 48).');
    }

    if (relatedOwnerOffenses.isNotEmpty) {
      buffer.writeln('\nV. TRÁCH NHIỆM CHỦ PHƯƠNG TIỆN LIÊN QUAN (ĐIỀU 32):');
      for (final ownerOff in relatedOwnerOffenses) {
        buffer.writeln('• ${ownerOff.canonicalName} (${ownerOff.primaryLegalRef})');
        buffer.writeln('  - Cá nhân: ${ownerOff.mainFinePenalty?.fineRangeText}');
        buffer.writeln('  - Tổ chức: ${ownerOff.mainFinePenalty?.orgFineRangeText}');
      }
    }

    buffer.writeln('==================================================');
    return buffer.toString();
  }
}
