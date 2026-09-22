import '../../core/utils/text_normalizer.dart';

class SearchNormalizer {
  /// Mở rộng từ viết tắt, từ lóng tiếng Việt thường gặp trong giao thông
  static String expandSlangAndAbbreviations(String input) {
    var text = ' ${TextNormalizer.normalize(input)} ';

    // Viết tắt phương tiện
    text = text.replaceAll(RegExp(r'\boto\b'), 'ô tô');
    text = text.replaceAll(RegExp(r'\bmoto\b'), 'mô tô');
    text = text.replaceAll(RegExp(r'\bxe may\b'), 'xe máy');
    text = text.replaceAll(RegExp(r'\bxm\b'), 'xe máy');

    // Viết tắt phủ định / giấy phép
    text = text.replaceAll(RegExp(r'\bk\b'), 'không');
    text = text.replaceAll(RegExp(r'\bko\b'), 'không');
    text = text.replaceAll(RegExp(r'\bkh\b'), 'không');
    text = text.replaceAll(RegExp(r'\bkg\b'), 'không');
    text = text.replaceAll(RegExp(r'\bgplx\b'), 'giấy phép lái xe');
    text = text.replaceAll(RegExp(r'\bblx\b'), 'bằng lái xe');
    text = text.replaceAll(RegExp(r'\bbang\b'), 'bằng');

    // Mũ bảo hiểm / nón
    text = text.replaceAll(RegExp(r'\bnon\b'), 'mũ bảo hiểm');
    text = text.replaceAll(RegExp(r'\bnon bao hiem\b'), 'mũ bảo hiểm');
    text = text.replaceAll(RegExp(r'\bmbh\b'), 'mũ bảo hiểm');
    text = text.replaceAll(RegExp(r'\bmu\b'), 'mũ');

    // Nồng độ cồn
    text = text.replaceAll(RegExp(r'\bndc\b'), 'nồng độ cồn');
    text = text.replaceAll(RegExp(r'\bthoi con\b'), 'nồng độ cồn');
    text = text.replaceAll(RegExp(r'\bcon\b'), 'cồn');

    // Số người / kẹp 3
    text = text.replaceAll(RegExp(r'\bkep 3\b'), 'chở 3 người');
    text = text.replaceAll(RegExp(r'\bkep 2\b'), 'chở 2 người');
    text = text.replaceAll(RegExp(r'\bcho 3\b'), 'chở 3 người');
    text = text.replaceAll(RegExp(r'\bcho 2\b'), 'chở 2 người');

    // TNGT
    text = text.replaceAll(RegExp(r'\btngt\b'), 'tai nạn giao thông');
    text = text.replaceAll(RegExp(r'\btai nan\b'), 'tai nạn giao thông');

    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
