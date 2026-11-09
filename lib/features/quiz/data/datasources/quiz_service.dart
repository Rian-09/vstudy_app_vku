import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quiz_models.dart';

class QuizService extends ChangeNotifier {
  QuizService._();

  static final QuizService instance = QuizService._();

  Exam? _activeExam;
  List<int?> _answers = [];
  List<bool> _checkedQuestions = [];
  int _currentQuestionIndex = 0;
  DateTime? _startedAt;
  bool _isTimed = false;
  QuizResult? _lastResult;
  final Map<String, Map<String, Question>> _savedWrongQuestions = {};

  Exam? get activeExam => _activeExam;
  int get currentQuestionIndex => _currentQuestionIndex;
  DateTime? get startedAt => _startedAt;
  bool get isTimed => _isTimed;
  QuizResult? get lastResult => _lastResult;
  List<int?> get answers => List.unmodifiable(_answers);
  List<bool> get checkedQuestions => List.unmodifiable(_checkedQuestions);
  int? get selectedAnswer =>
      _answers.isEmpty ? null : _answers[_currentQuestionIndex];
  bool get currentQuestionChecked =>
      _checkedQuestions.isNotEmpty && _checkedQuestions[_currentQuestionIndex];
  Question? get currentQuestion {
    final exam = _activeExam;
    if (exam == null || exam.questions.isEmpty) return null;
    return exam.questions[_currentQuestionIndex];
  }

  static var subjects = <Subject>[
    Subject(
      id: 'philosophy',
      name: 'Triết học',
      imageAsset: 'assets/images/quiz/subject_philosophy.png',
      questionCount: 120,
      examCount: 8,
      rating: 3.5,
      progress: .33,
    ),
    Subject(
      id: 'law',
      name: 'Pháp luật đại cương',
      imageAsset: 'assets/images/quiz/subject_law.png',
      questionCount: 120,
      examCount: 8,
      rating: 5,
      progress: .72,
    ),
  ];

  static var exams = <Exam>[
    _buildExam(
      id: 'philosophy-exam-1',
      subjectId: 'philosophy',
      title: 'Đề 1 - Chương 1',
      chapterTitle: 'Chương 1 - Lịch sử hình thành và phát triển',
      questionCount: 30,
      durationMinutes: 25,
      difficulty: 60,
      score: 9,
      completed: true,
      topic: 'Triết học Mác-Lênin',
    ),
    _buildExam(
      id: 'philosophy-exam-2',
      subjectId: 'philosophy',
      title: 'Đề 2 - Chương 1',
      chapterTitle: 'Chương 1 - Lịch sử hình thành và phát triển',
      questionCount: 30,
      durationMinutes: 25,
      difficulty: 60,
      score: 8,
      completed: true,
      topic: 'Triết học Mác-Lênin',
    ),
    _buildExam(
      id: 'philosophy-exam-3',
      subjectId: 'philosophy',
      title: 'Đề 2 - Chương 2',
      chapterTitle: 'Chương 2 - Duy vật Biện chứng',
      questionCount: 30,
      durationMinutes: 120,
      difficulty: 120,
      topic: 'Triết học Mác-Lênin',
    ),
    _buildExam(
      id: 'law-exam-1',
      subjectId: 'law',
      title: 'Đề 1 - Chương 1',
      chapterTitle: 'Chương 1 - Những vấn đề cơ bản về nhà nước',
      questionCount: 25,
      durationMinutes: 30,
      difficulty: 75,
      score: 7.5,
      completed: true,
      topic: 'Pháp luật đại cương',
    ),
    _buildExam(
      id: 'law-exam-2',
      subjectId: 'law',
      title: 'Đề 2 - Chương 2',
      chapterTitle: 'Chương 2 - Quy phạm pháp luật',
      questionCount: 30,
      durationMinutes: 35,
      difficulty: 80,
      score: 8.5,
      completed: true,
      topic: 'Pháp luật đại cương',
    ),
    _buildExam(
      id: 'law-exam-3',
      subjectId: 'law',
      title: 'Đề 3 - Chương 3',
      chapterTitle: 'Chương 3 - Quan hệ pháp luật',
      questionCount: 30,
      durationMinutes: 40,
      difficulty: 90,
      topic: 'Pháp luật đại cương',
    ),
  ];

  static final recentResults = [
    QuizResult(
      examId: 'law-exam-2',
      correctCount: 9,
      wrongCount: 1,
      skippedCount: 0,
      durationMinutes: 18,
      score: 9,
      completedAt: DateTime(2026, 11, 3),
    ),
    QuizResult(
      examId: 'law-exam-1',
      correctCount: 4,
      wrongCount: 6,
      skippedCount: 0,
      durationMinutes: 25,
      score: 4,
      completedAt: DateTime(2026, 11, 4),
    ),
    QuizResult(
      examId: 'philosophy-exam-1',
      correctCount: 9,
      wrongCount: 1,
      skippedCount: 0,
      durationMinutes: 21,
      score: 9,
      completedAt: DateTime(2026, 11, 2),
    ),
  ];

  Future<void> hydrateFromSupabase(SupabaseClient client) async {
    final subjectRows = await client
        .from('subjects')
        .select()
        .eq('is_active', true)
        .order('name');
    final quizRows = await client
        .from('quizzes')
        .select()
        .eq('is_published', true)
        .order('created_at');
    final questionRows = await client.from('quiz_questions').select();
    final optionRows = await client.from('quiz_options').select();

    final optionsByQuestion = <String, List<Map<String, dynamic>>>{};
    for (final raw in optionRows as List) {
      final row = Map<String, dynamic>.from(raw);
      optionsByQuestion
          .putIfAbsent(row['question_id'] as String, () => [])
          .add(row);
    }
    final questionsByQuiz = <String, List<Question>>{};
    for (final raw in questionRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final options = optionsByQuestion[row['id'] as String] ?? const [];
      final orderedOptions = [...options]
        ..sort((first, second) =>
            (first['option_index'] as int).compareTo(second['option_index'] as int));
      if (orderedOptions.length != 4) continue;
      final question = Question(
        id: row['id'] as String,
        examId: row['quiz_id'] as String,
        topic: row['chapter_title'] as String? ?? 'Ôn tập',
        chapterTitle: row['chapter_title'] as String? ?? 'Ôn tập',
        text: row['question_text'] as String,
        options: orderedOptions
            .map((option) => option['option_text'] as String)
            .toList(growable: false),
        correctIndex: orderedOptions.indexWhere(
          (option) => option['is_correct'] == true,
        ),
        explanation: row['explanation'] as String? ?? '',
      );
      questionsByQuiz.putIfAbsent(row['quiz_id'] as String, () => []).add(question);
    }

    final quizRowsBySubject = <String, List<Map<String, dynamic>>>{};
    for (final raw in quizRows as List) {
      final row = Map<String, dynamic>.from(raw);
      quizRowsBySubject
          .putIfAbsent(row['subject_id'] as String, () => [])
          .add(row);
    }
    final remoteExams = <Exam>[];
    for (final raw in quizRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final questions = questionsByQuiz[row['id'] as String] ?? const [];
      if (questions.isEmpty) continue;
      remoteExams.add(
        Exam(
          id: row['id'] as String,
          subjectId: row['subject_id'] as String,
          title: row['title'] as String,
          chapterTitle: row['description'] as String? ?? 'Ôn tập',
          questionCount: questions.length,
          durationMinutes: row['duration_minutes'] as int? ?? 30,
          difficulty: 0,
          questions: questions,
        ),
      );
    }
    if (remoteExams.isEmpty) return;

    final remoteSubjects = <Subject>[];
    for (final raw in subjectRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final id = row['id'] as String;
      final subjectExams = quizRowsBySubject[id] ?? const [];
      final questionCount = remoteExams
          .where((exam) => exam.subjectId == id)
          .fold<int>(0, (total, exam) => total + exam.questions.length);
      remoteSubjects.add(
        Subject(
          id: id,
          name: row['name'] as String,
          imageAsset: _subjectImage(row['code'] as String? ?? ''),
          questionCount: questionCount,
          examCount: subjectExams.length,
          rating: 0,
          progress: 0,
        ),
      );
    }
    if (remoteSubjects.isEmpty) return;
    subjects = remoteSubjects;
    exams = remoteExams;
    notifyListeners();
  }

  static String _subjectImage(String code) => switch (code) {
    'TRIET' => 'assets/images/quiz/subject_philosophy.png',
    'PLDC' => 'assets/images/quiz/subject_law.png',
    _ => 'assets/images/quiz/subject_philosophy.png',
  };

  List<Subject> get allSubjects => subjects;

  List<Exam> examsForSubject(String subjectId) => exams
      .where((exam) => exam.subjectId == subjectId)
      .toList(growable: false);

  Subject? subjectById(String id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  Exam? examById(String id) {
    for (final exam in exams) {
      if (exam.id == id) return exam;
    }
    return null;
  }

  List<Question> questionsForExam(String examId) =>
      examById(examId)?.questions ?? const [];

  List<Question> wrongQuestionsForSubject(String subjectId) => exams
      .where((exam) => exam.subjectId == subjectId)
      .expand((exam) => exam.questions)
      .where((question) => question.wasAnsweredIncorrectly)
      .followedBy(_savedWrongQuestions[subjectId]?.values ?? const [])
      .fold<Map<String, Question>>(
        {},
        (questionsById, question) => questionsById..[question.id] = question,
      )
      .values
      .toList(growable: false);

  void startSession(String examId, {bool timed = false}) {
    final exam = examById(examId);
    if (exam == null) throw ArgumentError.value(examId, 'examId');
    _activeExam = exam;
    _answers = List<int?>.filled(exam.questions.length, null);
    _checkedQuestions = List<bool>.filled(exam.questions.length, false);
    _currentQuestionIndex = 0;
    _startedAt = DateTime.now();
    _isTimed = timed;
    _lastResult = null;
    notifyListeners();
  }

  void selectAnswer(int optionIndex) {
    if (currentQuestionChecked || optionIndex < 0 || optionIndex > 3) return;
    _answers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }

  bool checkCurrentAnswer() {
    final question = currentQuestion;
    if (question == null || selectedAnswer == null) return false;
    _checkedQuestions[_currentQuestionIndex] = true;
    notifyListeners();
    return selectedAnswer == question.correctIndex;
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= _answers.length) return;
    _currentQuestionIndex = index;
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentQuestionIndex >= _answers.length - 1) return false;
    _currentQuestionIndex++;
    notifyListeners();
    return true;
  }

  QuizResult submitQuiz({DateTime? completedAt}) {
    final exam = _activeExam;
    if (exam == null) throw StateError('No active quiz session');
    var correctCount = 0;
    var wrongCount = 0;
    var skippedCount = 0;
    final topicCorrectCounts = <String, int>{};
    final topicTotalCounts = <String, int>{};
    for (var index = 0; index < exam.questions.length; index++) {
      final question = exam.questions[index];
      topicTotalCounts.update(
        question.topic,
        (total) => total + 1,
        ifAbsent: () => 1,
      );
      final answer = _answers[index];
      if (answer == null) {
        skippedCount++;
      } else if (answer == question.correctIndex) {
        correctCount++;
        topicCorrectCounts.update(
          question.topic,
          (total) => total + 1,
          ifAbsent: () => 1,
        );
      } else {
        wrongCount++;
        final subjectId = exam.subjectId;
        final subjectWrong = _savedWrongQuestions.putIfAbsent(
          subjectId,
          () => <String, Question>{},
        );
        final previousWrong = subjectWrong[question.id]?.wrongCount ?? 0;
        subjectWrong[question.id] = question.copyWith(
          previousAnswerIndex: answer,
          wrongCount: previousWrong + 1,
        );
      }
    }
    final elapsedSeconds = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inSeconds;
    final elapsedMinutes = elapsedSeconds ~/ 60;
    final result = QuizResult(
      examId: exam.id,
      correctCount: correctCount,
      wrongCount: wrongCount,
      skippedCount: skippedCount,
      durationMinutes: elapsedMinutes,
      score: exam.questions.isEmpty
          ? 0
          : correctCount / exam.questions.length * 100,
      completedAt: completedAt ?? DateTime.now(),
      answers: List.unmodifiable(_answers),
      checkedQuestions: List.unmodifiable(_checkedQuestions),
      durationSeconds: elapsedSeconds,
      topicCorrectCounts: Map.unmodifiable(topicCorrectCounts),
      topicTotalCounts: Map.unmodifiable(topicTotalCounts),
    );
    _lastResult = result;
    recentResults.insert(0, result);
    unawaited(_persistResult(result, exam));
    notifyListeners();
    return result;
  }

  Future<void> _persistResult(QuizResult result, Exam exam) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null || !_isUuid(exam.id)) return;

      final attempt = await client
          .from('quiz_attempts')
          .insert({
            'owner_id': userId,
            'quiz_id': exam.id,
            'started_at': (_startedAt ?? result.completedAt)
                .toUtc()
                .toIso8601String(),
            'completed_at': result.completedAt.toUtc().toIso8601String(),
            'score': result.score,
            'correct_count': result.correctCount,
            'wrong_count': result.wrongCount,
            'skipped_count': result.skippedCount,
            'duration_seconds': result.durationSeconds,
          })
          .select('id')
          .single();
      final attemptId = attempt['id'] as String;
      final answers = <Map<String, dynamic>>[];
      for (var index = 0; index < exam.questions.length; index++) {
        final answer = index < result.answers.length
            ? result.answers[index]
            : null;
        answers.add({
          'attempt_id': attemptId,
          'question_id': exam.questions[index].id,
          'selected_option_index': answer,
          'is_correct': answer == null
              ? null
              : answer == exam.questions[index].correctIndex,
        });
      }
      if (answers.isNotEmpty) {
        await client.from('attempt_answers').insert(answers);
      }
    } catch (_) {
      // The local result remains available when the network is unavailable.
    }
  }

  static bool _isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);

  /// Starts a deterministic mock exam created by the AI assistant.
  /// The generated exam intentionally uses the existing question bank so the
  /// normal quiz, result, review and wrong-question flows remain shared.
  String startAiGeneratedSession({
    String title = 'Đề ôn tập AI',
    int questionCount = 10,
    int difficulty = 60,
  }) {
    final source = examById('philosophy-exam-3') ?? exams.first;
    final id = 'ai-${DateTime.now().microsecondsSinceEpoch}';
    final count = questionCount.clamp(1, 40);
    final questions = List.generate(count, (index) {
      final sourceQuestion = source.questions[index % source.questions.length];
      return sourceQuestion.copyWith(
        id: '$id-q${index + 1}',
        examId: id,
        previousAnswerIndex: null,
        wrongCount: 0,
      );
    });
    final generated = Exam(
      id: id,
      subjectId: source.subjectId,
      title: title,
      chapterTitle: 'Tạo bởi Trợ lý V-Study',
      questionCount: questions.length,
      durationMinutes: source.durationMinutes,
      difficulty: difficulty,
      questions: questions,
    );
    exams.add(generated);
    startSession(id);
    return id;
  }

  int get totalQuestionCount =>
      exams.fold(0, (total, exam) => total + exam.questionCount);

  static Exam _buildExam({
    required String id,
    required String subjectId,
    required String title,
    required String chapterTitle,
    required int questionCount,
    required int durationMinutes,
    required int difficulty,
    required String topic,
    double? score,
    bool completed = false,
  }) {
    final seeds = subjectId == 'philosophy'
        ? _philosophyQuestions
        : _lawQuestions;
    final questions = List.generate(10, (index) {
      final seed = seeds[index];
      final previousAnswer = index % 4 == 1 || index % 4 == 3
          ? (seed.correctIndex + 1) % 4
          : null;
      return Question(
        id: '$id-q${index + 1}',
        examId: id,
        topic: switch (index) {
          < 3 => 'Nhận biết',
          < 7 => 'Thông hiểu',
          _ => 'Vận dụng',
        },
        chapterTitle: chapterTitle,
        text: seed.text,
        options: seed.options,
        correctIndex: seed.correctIndex,
        explanation: seed.explanation,
        previousAnswerIndex: previousAnswer,
        wrongCount: previousAnswer == null ? 0 : (index % 3) + 1,
      );
    });
    return Exam(
      id: id,
      subjectId: subjectId,
      title: title,
      chapterTitle: chapterTitle,
      questionCount: questionCount,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      questions: questions,
      score: score,
      isCompleted: completed,
    );
  }

  static const _philosophyQuestions = <_QuestionSeed>[
    _QuestionSeed(
      'Vấn đề cơ bản của triết học là gì?',
      [
        'Vật chất và ý thức',
        'Cá nhân và xã hội',
        'Tự nhiên và lịch sử',
        'Lý luận và thực tiễn',
      ],
      0,
      'Vấn đề cơ bản của triết học là mối quan hệ giữa vật chất và ý thức.',
    ),
    _QuestionSeed(
      'Theo chủ nghĩa duy vật, yếu tố nào có trước?',
      ['Ý thức', 'Vật chất', 'Tinh thần tuyệt đối', 'Cảm giác'],
      1,
      'Chủ nghĩa duy vật khẳng định vật chất có trước và quyết định ý thức.',
    ),
    _QuestionSeed(
      'Động lực bên trong của sự phát triển là gì?',
      ['Sự phủ định', 'Mâu thuẫn', 'Cân bằng', 'Tách rời'],
      1,
      'Mâu thuẫn là nguồn gốc và động lực bên trong của vận động, phát triển.',
    ),
    _QuestionSeed(
      'Quy luật lượng - chất chỉ ra điều gì?',
      [
        'Cách thức phát triển',
        'Nguồn gốc phát triển',
        'Xu hướng phát triển',
        'Tính ngẫu nhiên',
      ],
      0,
      'Quy luật lượng - chất chỉ ra cách thức vận động và phát triển.',
    ),
    _QuestionSeed(
      'Tiêu chuẩn kiểm nghiệm chân lý là gì?',
      ['Niềm tin', 'Thực tiễn', 'Số đông', 'Trực giác'],
      1,
      'Thực tiễn là tiêu chuẩn kiểm nghiệm chân lý.',
    ),
    _QuestionSeed(
      'Phủ định biện chứng có đặc điểm nào?',
      [
        'Kế thừa yếu tố hợp lý',
        'Xóa bỏ hoàn toàn',
        'Không tạo ra thay đổi',
        'Chỉ lặp lại cái cũ',
      ],
      0,
      'Phủ định biện chứng kế thừa các yếu tố tích cực của sự vật cũ.',
    ),
    _QuestionSeed(
      'Tồn tại xã hội quyết định yếu tố nào?',
      ['Ý thức xã hội', 'Dân số', 'Địa lý', 'Sản phẩm'],
      0,
      'Tồn tại xã hội quyết định ý thức xã hội.',
    ),
    _QuestionSeed(
      'Mối quan hệ giữa lý luận và thực tiễn là gì?',
      [
        'Tách biệt',
        'Thống nhất và tác động qua lại',
        'Đối lập tuyệt đối',
        'Không liên quan',
      ],
      1,
      'Lý luận hình thành từ thực tiễn và quay lại định hướng thực tiễn.',
    ),
    _QuestionSeed(
      'Ai là chủ thể sáng tạo lịch sử xã hội?',
      ['Quần chúng nhân dân', 'Một cá nhân duy nhất', 'Tự nhiên', 'Máy móc'],
      0,
      'Quần chúng nhân dân là chủ thể sáng tạo chân chính của lịch sử.',
    ),
    _QuestionSeed(
      'Quy luật thống nhất và đấu tranh của các mặt đối lập nói về gì?',
      [
        'Nguồn gốc phát triển',
        'Tốc độ phát triển',
        'Hình thức vận động',
        'Kết quả tất yếu',
      ],
      0,
      'Đấu tranh giữa các mặt đối lập là nguồn gốc, động lực phát triển.',
    ),
  ];

  static const _lawQuestions = <_QuestionSeed>[
    _QuestionSeed(
      'Quy phạm pháp luật có đặc điểm nào?',
      [
        'Tính bắt buộc chung',
        'Chỉ áp dụng một lần',
        'Không do nhà nước bảo đảm',
        'Tự nguyện hoàn toàn',
      ],
      0,
      'Quy phạm pháp luật là quy tắc xử sự chung có tính bắt buộc.',
    ),
    _QuestionSeed(
      'Văn bản có hiệu lực pháp lý cao nhất ở Việt Nam là gì?',
      ['Nghị định', 'Hiến pháp', 'Thông tư', 'Quyết định'],
      1,
      'Hiến pháp là đạo luật cơ bản có hiệu lực pháp lý cao nhất.',
    ),
    _QuestionSeed(
      'Năng lực pháp luật của cá nhân bắt đầu khi nào?',
      ['Khi đủ 18 tuổi', 'Khi sinh ra', 'Khi đi làm', 'Khi kết hôn'],
      1,
      'Năng lực pháp luật dân sự của cá nhân có từ khi người đó sinh ra.',
    ),
    _QuestionSeed(
      'Cơ quan nào thực hiện quyền lập hiến, lập pháp?',
      ['Chính phủ', 'Quốc hội', 'Tòa án', 'Ủy ban nhân dân'],
      1,
      'Quốc hội là cơ quan thực hiện quyền lập hiến và lập pháp.',
    ),
    _QuestionSeed(
      'Trách nhiệm pháp lý phát sinh khi nào?',
      [
        'Có hành vi vi phạm pháp luật',
        'Có tranh luận',
        'Có yêu cầu miệng',
        'Có thiệt hại tự nhiên',
      ],
      0,
      'Trách nhiệm pháp lý phát sinh từ hành vi vi phạm pháp luật.',
    ),
    _QuestionSeed(
      'Quan hệ pháp luật gồm những yếu tố nào?',
      [
        'Chủ thể, nội dung, khách thể',
        'Tài sản và thời gian',
        'Luật và án lệ',
        'Quyền và hình phạt',
      ],
      0,
      'Quan hệ pháp luật gồm chủ thể, nội dung và khách thể.',
    ),
    _QuestionSeed(
      'Hành vi nào là vi phạm pháp luật?',
      [
        'Trái pháp luật và có lỗi',
        'Không được yêu thích',
        'Gây tranh cãi',
        'Không có quy định',
      ],
      0,
      'Vi phạm pháp luật là hành vi trái pháp luật, có lỗi và do chủ thể có năng lực thực hiện.',
    ),
    _QuestionSeed(
      'Thời điểm có hiệu lực của văn bản được xác định theo gì?',
      [
        'Ngày ban hành luôn luôn',
        'Quy định trong văn bản',
        'Ngày được phổ biến miệng',
        'Ngày đăng báo bất kỳ',
      ],
      1,
      'Văn bản có hiệu lực theo thời điểm được quy định trong văn bản và pháp luật.',
    ),
    _QuestionSeed(
      'Áp dụng pháp luật là hoạt động của ai?',
      [
        'Cơ quan, người có thẩm quyền',
        'Mọi cá nhân tùy ý',
        'Chỉ doanh nghiệp',
        'Chỉ tổ chức xã hội',
      ],
      0,
      'Áp dụng pháp luật do cơ quan hoặc người có thẩm quyền thực hiện.',
    ),
    _QuestionSeed(
      'Phương pháp điều chỉnh của luật hành chính chủ yếu là gì?',
      [
        'Mệnh lệnh - quyền uy',
        'Thỏa thuận ngang bằng',
        'Tự do định đoạt',
        'Hòa giải tự nguyện',
      ],
      0,
      'Luật hành chính chủ yếu sử dụng phương pháp mệnh lệnh - quyền uy.',
    ),
  ];
}

class _QuestionSeed {
  const _QuestionSeed(
    this.text,
    this.options,
    this.correctIndex,
    this.explanation,
  );

  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}
