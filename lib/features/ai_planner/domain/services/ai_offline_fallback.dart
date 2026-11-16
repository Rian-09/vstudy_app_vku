class AiOfflineFallback {
  const AiOfflineFallback();

  String answerFor(String question) {
    final normalized = question.toLowerCase();
    if (normalized.contains('deadline') || normalized.contains('lịch')) {
      return 'Bạn đang offline. Hãy kiểm tra các deadline gần nhất trong Lịch, '
          'ưu tiên việc sắp đến hạn và chia thành các phiên học ngắn.';
    }
    if (normalized.contains('tóm tắt') || normalized.contains('tom tat')) {
      return 'Bạn đang offline nên mình chưa thể đọc tài liệu mới. '
          'Hãy mở tài liệu đã tải về hoặc thử lại khi có mạng.';
    }
    return 'Bạn đang offline nên trợ lý chưa thể phân tích câu hỏi mới. '
        'Mình sẽ thử lại khi có kết nối mạng.';
  }
}
