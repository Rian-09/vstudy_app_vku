import '../../data/models/quiz_models.dart';

abstract interface class QuizRepository {
  List<Subject> get subjects;
  List<Exam> get exams;
  List<QuizResult> get recentResults;
  Exam? get activeExam;
  int get currentQuestionIndex;
  QuizResult? get lastResult;
  List<int?> get answers;
  int? get selectedAnswer;
  bool get currentQuestionChecked;
  Question? get currentQuestion;

  Subject? subjectById(String id);
  Exam? examById(String id);
  List<Exam> examsForSubject(String subjectId);
  List<Question> questionsForExam(String examId);
  List<Question> wrongQuestionsForSubject(String subjectId);
  void startSession(String examId, {bool timed = false});
  void selectAnswer(int optionIndex);
  bool checkCurrentAnswer();
  void goToQuestion(int index);
  bool nextQuestion();
  QuizResult submitQuiz({DateTime? completedAt});
}
