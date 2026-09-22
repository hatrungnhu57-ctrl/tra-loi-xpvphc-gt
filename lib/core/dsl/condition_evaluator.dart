class ConditionEvaluator {
  /// Đánh giá một cây điều kiện conditionJson với facts đã trích xuất
  static bool evaluate(Map<String, dynamic>? condition, Map<String, dynamic> facts) {
    if (condition == null || condition.isEmpty) {
      return true; // Không có điều kiện -> luôn thỏa
    }

    // Xử lý 'all' (AND)
    if (condition.containsKey('all')) {
      final list = condition['all'] as List<dynamic>;
      for (final item in list) {
        if (!evaluate(item as Map<String, dynamic>, facts)) {
          return false;
        }
      }
      return true;
    }

    // Xử lý 'any' (OR)
    if (condition.containsKey('any')) {
      final list = condition['any'] as List<dynamic>;
      for (final item in list) {
        if (evaluate(item as Map<String, dynamic>, facts)) {
          return true;
        }
      }
      return false;
    }

    // Xử lý 'not' (NOT)
    if (condition.containsKey('not')) {
      final item = condition['not'] as Map<String, dynamic>;
      return !evaluate(item, facts);
    }

    // Đánh giá biểu thức so sánh đơn: {"field": "x", "op": ...}
    if (condition.containsKey('field')) {
      final field = condition['field'] as String;
      final factValue = _resolveField(field, facts);

      if (condition.containsKey('eq')) {
        return factValue == condition['eq'];
      }
      if (condition.containsKey('neq')) {
        return factValue != condition['neq'];
      }
      if (condition.containsKey('gt')) {
        final threshold = (condition['gt'] as num).toDouble();
        if (factValue is num) {
          return factValue.toDouble() > threshold;
        }
        return false;
      }
      if (condition.containsKey('gte')) {
        final threshold = (condition['gte'] as num).toDouble();
        if (factValue is num) {
          return factValue.toDouble() >= threshold;
        }
        return false;
      }
      if (condition.containsKey('lt')) {
        final threshold = (condition['lt'] as num).toDouble();
        if (factValue is num) {
          return factValue.toDouble() < threshold;
        }
        return false;
      }
      if (condition.containsKey('lte')) {
        final threshold = (condition['lte'] as num).toDouble();
        if (factValue is num) {
          return factValue.toDouble() <= threshold;
        }
        return false;
      }
      if (condition.containsKey('between')) {
        final range = condition['between'] as List<dynamic>;
        if (factValue is num && range.length >= 2) {
          final min = (range[0] as num).toDouble();
          final max = (range[1] as num).toDouble();
          final val = factValue.toDouble();
          return val >= min && val <= max;
        }
        return false;
      }
      if (condition.containsKey('in')) {
        final list = condition['in'] as List<dynamic>;
        return list.contains(factValue);
      }
      if (condition.containsKey('not_in')) {
        final list = condition['not_in'] as List<dynamic>;
        return !list.contains(factValue);
      }
      if (condition.containsKey('exists')) {
        final shouldExist = condition['exists'] as bool;
        final exists = factValue != null;
        return exists == shouldExist;
      }
    }

    return true;
  }

  static dynamic _resolveField(String path, Map<String, dynamic> facts) {
    if (facts.containsKey(path)) return facts[path];

    final parts = path.split('.');
    dynamic current = facts;
    for (final p in parts) {
      if (current is Map<String, dynamic> && current.containsKey(p)) {
        current = current[p];
      } else {
        return null;
      }
    }
    return current;
  }
}
