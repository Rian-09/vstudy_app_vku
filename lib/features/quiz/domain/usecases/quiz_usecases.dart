import '../../data/models/quiz_models.dart';
import '../repositories/quiz_repository.dart';

class QuizUseCases {
  const QuizUseCases(this._repository);

  final QuizRepository _repository;

  List<Subject> get subjects => _repository.subjects;
  List<Exam> get exams => _repository.exams;
  List<QuizResult> get recentResults => _repository.recentResults;
  Exam? get activeExam => _repository.activeExam;
  int get currentQuestionIndex => _repository.currentQuestionIndex;
  QuizResult? get lastResult => _repository.lastResult;
  List<int?> get answers => _repository.answers;
  int? get selectedAnswer => _repository.selectedAnswer;
  bool get currentQuestionChecked => _repository.currentQuestionChecked;
  Question? get currentQuestion => _repository.currentQuestion;

  Subject? subjectById(String id) => _repository.subjectById(id);
  Exam? examById(String id) => _repository.examById(id);
  List<Exam> examsForSubject(String subjectId) =>
      _repository.examsForSubject(subjectId);
  List<Question> questionsForExam(String examId) =>
      _repository.questionsForExam(examId);
  List<Question> wrongQuestionsForSubject(String subjectId) =>
      _repository.wrongQuestionsForSubject(subjectId);
  void startSession(String examId, {bool timed = false}) =>
      _repository.startSession(examId, timed: timed);
  void selectAnswer(int optionIndex) => _repository.selectAnswer(optionIndex);
  bool checkCurrentAnswer() => _repository.checkCurrentAnswer();
  void goToQuestion(int index) => _repository.goToQuestion(index);
  bool nextQuestion() => _repository.nextQuestion();
  QuizResult submitQuiz({DateTime? completedAt}) =>
      _repository.submitQuiz(completedAt: completedAt);
}
