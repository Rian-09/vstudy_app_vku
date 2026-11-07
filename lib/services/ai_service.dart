import '../models/ai_models.dart';
import 'quiz_service.dart';

class AiService {
  AiService._();

  static final instance = AiService._();

  final List<AiChatMessage> chat = [
    const AiChatMessage(
      text: 'Giải thích định lý giá trị trung bình cho mình nhé',
      fromUser: true,
    ),
    const AiChatMessage(
      text: 'Nếu f liên tục trên [a, b] và khả vi trên (a, b) thì tồn tại c trong (a, b) sao cho f′(c) = (f(b) − f(a)) / (b − a).\n\nHiểu đơn giản: tại một điểm nào đó, độ dốc tiếp tuyến bằng độ dốc trung bình của đoạn.',
      fromUser: false,
    ),
    const AiChatMessage(text: 'Cho mình ví dụ với f(x) = x²', fromUser: true),
  ];

  final List<AiRoadmapTask> roadmapTasks = [
    const AiRoadmapTask(title: 'Đọc lại Chương 3', subtitle: '45 phút'),
    const AiRoadmapTask(title: 'Làm đề 20 câu Chương 3', subtitle: '25 phút'),
    const AiRoadmapTask(title: 'Ôn flashcard 30 thẻ', subtitle: '15 phút'),
    const AiRoadmapTask(title: 'Xem lại 4 câu sai', subtitle: '10 phút'),
  ];

  static const suggestions = [
    'Tóm tắt chương này giúp mình',
    'Giải thích khái niệm dễ hiểu hơn',
    'Tạo câu hỏi ôn tập nhanh',
  ];

  static const recentItems = <(String, String, String)>[
    ('Hỏi đáp · Cách ôn tập SXTK', 'SXTK · 10 phút trước', '/chat'),
    ('Tóm tắt · Chương 3 Giải tích', 'GT1 · Hôm qua', '/pick-documents'),
    ('Đề ôn · Mạng máy tính', '20 câu · 12/10', '/create-test'),
    (
      'Lộ trình · Tuần đến thi nên sắp lịch học như nào?',
      'Tôi sẽ lên lịch cho bạn...',
      '/roadmap',
    ),
  ];

  static const replies = [
    'Mình đã phân tích nội dung. Bạn có thể bắt đầu từ các khái niệm chính, sau đó luyện tập bằng câu hỏi trắc nghiệm.',
    'Theo tài liệu, ý chính là mối quan hệ giữa lý luận và thực tiễn. Hãy nhớ: lý luận bắt nguồn từ thực tiễn và định hướng thực tiễn.',
    'Mình gợi ý bạn chia nội dung thành 3 phần nhỏ và ôn lại sau mỗi phần để ghi nhớ lâu hơn.',
  ];

  AiSummaryData summaryFor(String documentTitle) => AiSummaryData(
    title: documentTitle,
    shortText: 'Tài liệu trình bày các khái niệm nền tảng, mối quan hệ giữa các nội dung và cách vận dụng trong học tập.',
    detailText: 'Nội dung chính được chia thành các luận điểm: khái niệm cốt lõi, đặc điểm, mối quan hệ tác động qua lại và ví dụ minh họa. Khi ôn tập, hãy ghi nhớ từ khóa trước rồi liên hệ với câu hỏi thực tế.',
  );

  String replyFor(int index) => replies[index % replies.length];

  String generateMockTest({
    required String title,
    required int questionCount,
    required int difficulty,
  }) => QuizService.instance.startAiGeneratedSession(
    title: title,
    questionCount: questionCount,
    difficulty: difficulty,
  );

  void toggleTask(int index) {
    roadmapTasks[index] = roadmapTasks[index].copyWith(
      done: !roadmapTasks[index].done,
    );
  }

  void addSuggestedTask() {
    if (roadmapTasks.any(
      (task) => task.title == 'Ôn thêm 20 phút phần Lagrange',
    ))
      return;
    roadmapTasks.add(
      const AiRoadmapTask(
        title: 'Ôn thêm 20 phút phần Lagrange',
        subtitle: '20 phút',
      ),
    );
  }
}
