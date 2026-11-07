import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_service.dart';
import '../models/quiz_models.dart';

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(this._dataSource);

  final QuizService _dataSource;

  @override
  List<Subject> get subjects => _dataSource.allSubjects;

  @override
  List<Exam> get exams => QuizService.exams;

  @override
  List<QuizResult> get recentResults => QuizService.recentResults;

  @override
  Exam? get activeExam => _dataSource.activeExam;

  @override
  int get currentQuestionIndex => _dataSource.currentQuestionIndex;

  @override
  QuizResult? get lastResult => _dataSource.lastResult;

  @override
  List<int?> get answers => _dataSource.answers;

  @override
  int? get selectedAnswer => _dataSource.selectedAnswer;

  @override
  bool get currentQuestionChecked => _dataSource.currentQuestionChecked;

  @override
  Question? get currentQuestion => _dataSource.currentQuestion;

  @override
  Subject? subjectById(String id) => _dataSource.subjectById(id);

  @override
  Exam? examById(String id) => _dataSource.examById(id);

  @override
  List<Exam> examsForSubject(String subjectId) =>
      _dataSource.examsForSubject(subjectId);

  @override
  List<Question> questionsForExam(String examId) =>
      _dataSource.questionsForExam(examId);

  @override
  List<Question> wrongQuestionsForSubject(String subjectId) =>
      _dataSource.wrongQuestionsForSubject(subjectId);

  @override
  void startSession(String examId, {bool timed = false}) =>
      _dataSource.startSession(examId, timed: timed);

  @override
  void selectAnswer(int optionIndex) => _dataSource.selectAnswer(optionIndex);

  @override
  bool checkCurrentAnswer() => _dataSource.checkCurrentAnswer();

  @override
  void goToQuestion(int index) => _dataSource.goToQuestion(index);

  @override
  bool nextQuestion() => _dataSource.nextQuestion();

  @override
  QuizResult submitQuiz({DateTime? completedAt}) =>
      _dataSource.submitQuiz(completedAt: completedAt);
}
