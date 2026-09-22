import '../../domain/entities/search_query_intent.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../domain/enums/subject_type.dart';
import '../../core/utils/text_normalizer.dart';
import 'citation_parser.dart';
import 'search_normalizer.dart';

class IntentFactExtractor {
  /// Trích xuất facts có cấu trúc từ câu truy vấn tự nhiên
  static SearchQueryIntent extract(String rawQuery) {
    final norm = TextNormalizer.normalize(rawQuery);
    final unaccented = TextNormalizer.removeDiacritics(norm);
    final expanded = SearchNormalizer.expandSlangAndAbbreviations(norm);
    final expandedUnaccented = TextNormalizer.removeDiacritics(expanded);

    // 1. Phân tích Citation (Điều / Khoản / Điểm) nếu có
    final citation = CitationParser.parse(rawQuery);

    // 2. Nhận diện loại phương tiện (VehicleType)
    VehicleType? vehicle;
    if (RegExp(r'\b(o\s*to|oto|xe\s*hoi|xe\s*tai|xe\s*con|o\s*to\s*khach)\b').hasMatch(unaccented)) {
      vehicle = VehicleType.car;
    } else if (RegExp(r'\b(xe\s*may|mo\s*to|moto|xe\s*gan\s*may|150cc|125cc|110cc|175cc|150\s*cc|125\s*cc|sh150|exciter|winner)\b').hasMatch(unaccented)) {
      vehicle = VehicleType.motorcycle;
    } else if (RegExp(r'\b(xe\s*dap|xe\s*dap\s*dien|xe\s*dien|xich\s*lo)\b').hasMatch(unaccented)) {
      vehicle = VehicleType.bicycle;
    } else if (RegExp(r'\b(di\s*bo|nguoi\s*di\s*bo)\b').hasMatch(unaccented)) {
      vehicle = VehicleType.pedestrian;
    } else if (RegExp(r'\b(xe\s*may\s*chuyen\s*dung|may\s*xuc|may\s*ui)\b').hasMatch(unaccented)) {
      vehicle = VehicleType.specialMachinery;
    }

    // 3. Trích xuất dung tích xi lanh (Engine CC)
    double? engineCc;
    final ccMatch = RegExp(r'\b([0-9]{2,4})\s*(?:cc|cm3)?\b').allMatches(unaccented);
    for (final m in ccMatch) {
      final val = double.tryParse(m.group(1) ?? '');
      // Giá trị dung tích xe máy phổ biến: 50, 110, 125, 135, 150, 155, 160, 175, 250, 300, 400, 500, 650, 1000...
      if (val != null && (val == 50 || val == 110 || val == 125 || val == 135 || val == 150 || val == 155 || val == 160 || val == 175 || val >= 200)) {
        // Tránh nhầm lẫn với tốc độ (nếu có dấu gạch chéo '/')
        if (!unaccented.contains('/')) {
          engineCc = val;
          vehicle ??= VehicleType.motorcycle;
          break;
        }
      }
    }

    // 4. Trích xuất tình trạng GPLX (Has Valid License)
    bool? hasValidLicense;
    if (RegExp(r'\b(khong\s*(?:co\s*)?(?:bang|gplx|blx|giay\s*phep)|k\s*(?:co\s*)?(?:bang|gplx|blx)|chua\s*co\s*bang|khong\s*bang|k\s*gplx|ko\s*bang)\b').hasMatch(unaccented)) {
      hasValidLicense = false;
    }

    // 5. Trích xuất Tốc độ: dạng "76/60", "76 / 60", "vuot 16km", "chay 80 tren 60"
    double? speedMeasured;
    double? speedLimit;
    double? speedExcess;

    final slashSpeedMatch = RegExp(r'\b([0-9]{2,3})\s*\/\s*([0-9]{2,3})\b').firstMatch(unaccented);
    if (slashSpeedMatch != null) {
      speedMeasured = double.tryParse(slashSpeedMatch.group(1) ?? '');
      speedLimit = double.tryParse(slashSpeedMatch.group(2) ?? '');
      if (speedMeasured != null && speedLimit != null) {
        speedExcess = speedMeasured - speedLimit;
      }
    } else {
      final excessMatch = RegExp(r'\b(?:vuot|qua|chay\s*qua)\s*([0-9]{1,3})\s*(?:km|km\/h)?\b').firstMatch(unaccented);
      if (excessMatch != null) {
        speedExcess = double.tryParse(excessMatch.group(1) ?? '');
      }
    }

    // 6. Trích xuất Nồng độ cồn: dạng "cồn 0.32", "0.32 moto", "0.25", "ndc 0.4"
    double? alcoholBreath;
    double? alcoholBlood;

    final breathMatch = RegExp(r'\b(?:con|ndc|nong\s*do\s*con|thoi\s*con)?\s*(0\.[0-9]{1,3})\b').firstMatch(unaccented);
    if (breathMatch != null) {
      alcoholBreath = double.tryParse(breathMatch.group(1) ?? '');
    }

    final bloodMatch = RegExp(r'\b(?:mau|blood)\s*([0-9]{1,3}(?:\.[0-9]+)?)\s*(?:mg)?\b').firstMatch(unaccented);
    if (bloodMatch != null) {
      alcoholBlood = double.tryParse(bloodMatch.group(1) ?? '');
    }

    // 7. Trích xuất Số người chở: "kẹp 3", "chở 3", "chở 2 người", "cho 3"
    int? passengerCount;
    if (RegExp(r'\b(kep\s*3|cho\s*3|cho\s*3\s*nguoi|3\s*nguoi)\b').hasMatch(unaccented)) {
      passengerCount = 3;
      vehicle ??= VehicleType.motorcycle;
    } else if (RegExp(r'\b(kep\s*2|cho\s*2|cho\s*2\s*nguoi|2\s*nguoi)\b').hasMatch(unaccented)) {
      passengerCount = 2;
      vehicle ??= VehicleType.motorcycle;
    }

    // 8. Trích xuất Mũ bảo hiểm (Nón bảo hiểm)
    bool? hasHelmet;
    if (RegExp(r'\b(khong\s*(?:doi\s*)?(?:mu|non|mbh|mu\s*bao\s*hiem|non\s*bao\s*hiem)|ko\s*mu|ko\s*non|k\s*mu|k\s*non)\b').hasMatch(unaccented)) {
      hasHelmet = false;
      vehicle ??= VehicleType.motorcycle;
    }

    // 9. Trích xuất Gây tai nạn giao thông (TNGT)
    bool? causedAccident;
    if (RegExp(r'\b(gay\s*tai\s*nan|tngt|va\s*cham|tong\s*xe|dam\s*xe)\b').hasMatch(unaccented)) {
      causedAccident = true;
    }

    // 10. Trích xuất Trách nhiệm chủ xe (Owner Liability)
    bool isOwner = false;
    if (RegExp(r'\b(giao\s*xe|cho\s*muon\s*xe|chu\s*xe|chu\s*phuong\s*tien|dung\s*ten\s*xe)\b').hasMatch(unaccented)) {
      isOwner = true;
    }

    // Nếu câu truy vấn có "giao xe cho người không bằng", tự động hiểu:
    if (unaccented.contains('giao xe') && (unaccented.contains('khong bang') || unaccented.contains('k bang') || unaccented.contains('k gplx'))) {
      isOwner = true;
      hasValidLicense = false;
    }

    // Danh sách từ khóa trích xuất
    final extractedKeywords = <String>[];
    if (vehicle != null) extractedKeywords.add(vehicle.label);
    if (hasValidLicense == false) extractedKeywords.add('không có GPLX');
    if (hasHelmet == false) extractedKeywords.add('không đội mũ bảo hiểm');
    if (speedExcess != null) extractedKeywords.add('quá tốc độ $speedExcess km/h');
    if (alcoholBreath != null) extractedKeywords.add('cồn $alcoholBreath mg/L');
    if (passengerCount != null) extractedKeywords.add('chở $passengerCount người');
    if (isOwner) extractedKeywords.add('chủ phương tiện');

    return SearchQueryIntent(
      rawQuery: rawQuery,
      normalizedQuery: norm,
      vehicleType: vehicle,
      subjectType: isOwner ? SubjectType.ownerIndividual : SubjectType.driver,
      citation: citation,
      speedMeasured: speedMeasured,
      speedLimit: speedLimit,
      speedExcess: speedExcess,
      alcoholBreathMgL: alcoholBreath,
      alcoholBloodMg100ml: alcoholBlood,
      engineCc: engineCc,
      passengerCount: passengerCount,
      hasValidLicense: hasValidLicense,
      hasHelmet: hasHelmet,
      causedAccident: causedAccident,
      isOwnerLiabilityLookup: isOwner,
      extractedKeywords: extractedKeywords,
    );
  }
}
