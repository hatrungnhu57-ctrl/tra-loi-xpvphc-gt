class TextNormalizer {
  static const Map<String, String> _vietnameseMap = {
    'a': 'áàảãạăắằẳẵặâấầẩẫậ',
    'A': 'ÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬ',
    'd': 'đ',
    'D': 'Đ',
    'e': 'éèẻẽẹêếềểễệ',
    'E': 'ÉÈẺẼẸÊẾỀỂỄỆ',
    'i': 'íìỉĩị',
    'I': 'ÍÌỈĨỊ',
    'o': 'óòỏõọôốồổỗộơớờởỡợ',
    'O': 'ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ',
    'u': 'úùủũụưứừửữự',
    'U': 'ÚÙỦŨỤƯỨỪỬỮỰ',
    'y': 'ýỳỷỹỵ',
    'Y': 'ÝỲỶỸỴ',
  };

  /// Chuyển chuỗi tiếng Việt thành không dấu, chữ thường, chuẩn hóa khoảng trắng
  static String removeDiacritics(String input) {
    var result = input;
    _vietnameseMap.forEach((replacement, chars) {
      for (var i = 0; i < chars.length; i++) {
        result = result.replaceAll(chars[i], replacement);
      }
    });
    return result;
  }

  /// Chuẩn hóa chuỗi tìm kiếm toàn diện
  static String normalize(String input) {
    if (input.trim().isEmpty) return '';
    var text = input.trim().toLowerCase();

    // Thay thế ký tự đặc biệt thừa nhưng giữ lại dấu chấm số thập phân (0.32), gạch chéo (76/60), gạch ngang
    text = text.replaceAll(RegExp(r'[,;!?()"\x27\[\]{}]'), ' ');
    // Thay thế dấu chấm nếu không nằm giữa 2 chữ số hoặc chữ cái (ví dụ: cuối câu "oto." -> "oto ")
    text = text.replaceAll(RegExp(r'(?<![a-zA-Z0-9])\.|\.(?![a-zA-Z0-9])'), ' ');

    // Thu gọn khoảng trắng
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Chuẩn hóa cho FTS5 (tạo cả phiên bản có dấu và không dấu nối lại)
  static String createSearchIndex(String input, List<String> aliases, List<String> tags) {
    final tokens = <String>{};
    final norm = normalize(input);
    final unaccented = removeDiacritics(norm);

    tokens.addAll(norm.split(' '));
    tokens.addAll(unaccented.split(' '));

    for (final alias in aliases) {
      final aNorm = normalize(alias);
      tokens.addAll(aNorm.split(' '));
      tokens.addAll(removeDiacritics(aNorm).split(' '));
    }

    for (final tag in tags) {
      final tNorm = normalize(tag);
      tokens.addAll(tNorm.split(' '));
      tokens.addAll(removeDiacritics(tNorm).split(' '));
    }

    return tokens.where((t) => t.isNotEmpty).join(' ');
  }
}
