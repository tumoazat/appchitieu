/// Parser phân tích text từ hóa đơn để trích xuất thông tin giao dịch
class ReceiptParser {
  /// Trích xuất số tiền từ text hóa đơn
  static double? extractAmount(String text) {
    // Tìm các pattern số tiền: 1.000.000, 1,000,000, 1000000, 150.000đ
    final patterns = [
      RegExp(r'(\d{1,3}(?:[.,]\d{3})+)(?:đ|vnd|vnđ)?', caseSensitive: false),
      RegExp(r'(\d+)(?:đ|vnd|vnđ)', caseSensitive: false),
      RegExp(r'tổng[:\s]+(\d[\d.,]+)', caseSensitive: false),
      RegExp(r'total[:\s]+(\d[\d.,]+)', caseSensitive: false),
      RegExp(r'thành tiền[:\s]+(\d[\d.,]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match
            .group(1)!
            .replaceAll('.', '')
            .replaceAll(',', '');
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  /// Trích xuất mô tả từ text hóa đơn
  static String extractDescription(String text) {
    // Lấy dòng đầu tiên có nghĩa (dài hơn 3 ký tự)
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.length > 3)
        .toList();

    if (lines.isNotEmpty) {
      return lines.first.length > 50
          ? lines.first.substring(0, 50)
          : lines.first;
    }
    return 'Hóa đơn';
  }

  /// Trích xuất ngày từ text hóa đơn
  static DateTime? extractDate(String text) {
    // Pattern ngày: dd/MM/yyyy, dd-MM-yyyy, yyyy-MM-dd
    final patterns = [
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})'),
      RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final g1 = match.group(1)!;
          final g2 = match.group(2)!;
          final g3 = match.group(3)!;

          if (g3.length == 4) {
            // Format: dd/MM/yyyy
            return DateTime(
              int.parse(g3),
              int.parse(g2),
              int.parse(g1),
            );
          } else {
            // Format: yyyy-MM-dd
            return DateTime(
              int.parse(g1),
              int.parse(g2),
              int.parse(g3),
            );
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Phân tích toàn bộ hóa đơn, trả về map dữ liệu
  static Map<String, dynamic> parse(String text) {
    return {
      'amount': extractAmount(text),
      'description': extractDescription(text),
      'date': extractDate(text),
      'rawText': text,
    };
  }
}
