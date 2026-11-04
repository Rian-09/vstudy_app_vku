// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/calendar_event.dart';
import 'package:flutter_application_1/models/document.dart';
import 'package:flutter_application_1/screens/calendar/calendar_screen.dart';
import 'package:flutter_application_1/screens/calendar/event_detail_screen.dart';
import 'package:flutter_application_1/screens/calendar/event_form_screen.dart';
import 'package:flutter_application_1/screens/documents/document_viewer_screen.dart';
import 'package:flutter_application_1/screens/documents/documents_screen.dart';
import 'package:flutter_application_1/screens/documents/library_screen.dart';
import 'package:flutter_application_1/screens/documents/widgets/document_widgets.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/profile/edit_profile_screen.dart';
import 'package:flutter_application_1/screens/profile/profile_screen.dart';
import 'package:flutter_application_1/screens/quiz/exam_detail_screen.dart';
import 'package:flutter_application_1/screens/quiz/quiz_home_screen.dart';
import 'package:flutter_application_1/screens/quiz/subject_quiz_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/calendar_service.dart';
import 'package:flutter_application_1/services/quiz_service.dart';
import 'package:flutter_application_1/widgets/profile_dialogs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo and registered accounts authenticate with normalized emails', () {
    final authService = AuthService.instance;

    expect(
      authService.login(email: ' People@Gmail.com ', password: 'admin123'),
      isTrue,
    );
    expect(authService.currentUserName, 'Tom');
    expect(
      authService.register(
        name: 'Taylor',
        email: ' PEOPLE@gmail.com ',
        password: 'other-pass',
      ),
      isFalse,
    );

    expect(
      authService.register(
        name: 'Alex',
        email: 'alex@example.com',
        password: 'registered-pass',
      ),
      isTrue,
    );
    expect(
      authService.login(
        email: ' ALEX@EXAMPLE.COM ',
        password: 'registered-pass',
      ),
      isTrue,
    );
    expect(authService.currentUserName, 'Alex');
    expect(
      authService.login(email: 'people@gmail.com', password: 'wrong'),
      isFalse,
    );
  });

  testWidgets('splash animates to the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('V - Study'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });

  testWidgets('home greets the signed-in user and switches tabs', (
    WidgetTester tester,
  ) async {
    final authService = AuthService.instance;
    authService.register(
      name: 'Taylor',
      email: 'home-test@example.com',
      password: 'study123',
    );
    expect(
      authService.login(email: 'home-test@example.com', password: 'study123'),
      isTrue,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(),
        routes: {'/profile': (context) => const ProfileScreen()},
      ),
    );

    expect(find.text('Xin chào, Taylor!'), findsOneWidget);
    expect(find.text('100/180 phút'), findsOneWidget);
    expect(find.text('Truy cập nhanh'), findsOneWidget);
    expect(find.text('Tuần này'), findsOneWidget);
    expect(find.byTooltip('Trợ lý AI'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.semanticLabel == 'Mở hồ sơ',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Trợ lý AI'), findsOneWidget);
    await tester.tap(find.byTooltip('Trợ lý AI'));
    await tester.pump();
    expect(find.text('Trợ lý AI sắp ra mắt'), findsOneWidget);

    await tester.tap(find.byTooltip('Quiz'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizHomeScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Xin chào, Taylor!'), findsOneWidget);
  });

  testWidgets('home deadline cards fit a narrow viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('Sắp đến'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile edits update the shared user and return to profile', (
    WidgetTester tester,
  ) async {
    final authService = AuthService.instance;
    expect(
      authService.login(email: 'people@gmail.com', password: 'admin123'),
      isTrue,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        routes: {'/edit-profile': (context) => const EditProfileScreen()},
      ),
    );
    expect(find.text('Tom'), findsOneWidget);

    final avatar = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Ảnh đại diện',
    );
    await tester.tap(avatar);
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'Tommy');
    await tester.pump();
    await tester.ensureVisible(find.text('Lưu thay đổi'));
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(authService.currentUserName, 'Tommy');
    expect(find.text('Tommy'), findsOneWidget);
  });

  testWidgets('logout confirmation clears the session and opens Login', (
    WidgetTester tester,
  ) async {
    final authService = AuthService.instance;
    expect(
      authService.login(email: 'people@gmail.com', password: 'admin123'),
      isTrue,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        routes: {
          '/login': (context) =>
              const Scaffold(body: Text('Login placeholder')),
        },
      ),
    );
    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(ConfirmDialog),
            matching: find.text('Đăng xuất'),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(authService.currentUser, isNull);
    expect(find.text('Login placeholder'), findsOneWidget);
  });

  testWidgets('document filters switch in place and library back returns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(initialIndex: 4),
        routes: {
          '/documents/viewer': (context) => DocumentViewerScreen(
            documentId: ModalRoute.of(context)!.settings.arguments as String,
          ),
          '/documents/library': (context) =>
              const MainShell(initialIndex: 4, showLibrary: true),
        },
      ),
    );

    expect(find.byType(DocumentsScreen), findsOneWidget);
    await tester.tap(find.text('Tài liệu ôn thi & Đề'));
    await tester.pumpAndSettle();
    expect(find.byType(DocumentsScreen), findsOneWidget);
    expect(
      find.text('Đề thi chuẩn kèm đáp án chi tiết môn Triết học Mác - Lênin'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Thư viện tài liệu đã lưu'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại tài liệu'));
    await tester.pumpAndSettle();
    expect(find.byType(DocumentsScreen), findsOneWidget);

    await tester.tap(find.text('Tài liệu môn học'));
    await tester.pumpAndSettle();
    final firstDocumentTitle = find.text(
      'Slide bài giảng Chương 2 - Lịch sử Đảng',
    );
    await tester.ensureVisible(firstDocumentTitle);
    await tester.tap(firstDocumentTitle);
    await tester.pumpAndSettle();
    expect(find.byType(DocumentViewerScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(DocumentsScreen), findsOneWidget);
  });

  testWidgets('viewer download shows success and saves to Library', (
    WidgetTester tester,
  ) async {
    final document = DocumentRepository.instance.documents.first;
    await tester.pumpWidget(
      MaterialApp(
        home: DocumentViewerScreen(documentId: document.id),
        routes: {
          '/documents/library': (context) =>
              const MainShell(initialIndex: 4, showLibrary: true),
        },
      ),
    );

    await tester.ensureVisible(find.text('Tải xuống (43MB)'));
    await tester.tap(find.text('Tải xuống (43MB)'));
    await tester.pumpAndSettle();
    expect(find.byType(DownloadSheet), findsOneWidget);
    await tester.tap(find.text('Bản nén'));
    await tester.pump();
    await tester.ensureVisible(find.text('Xác nhận tải về (8.2 MB)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận tải về (8.2 MB)'));
    for (var tick = 0; tick < 22; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(
      DocumentRepository.instance.findById(document.id)?.isDownloaded,
      isTrue,
    );
    expect(find.byType(DownloadSuccessPopup), findsOneWidget);
    await tester.tap(find.text('Lưu vào Thư viện yêu thích'));
    await tester.pumpAndSettle();
    expect(DocumentRepository.instance.findById(document.id)?.isSaved, isTrue);
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('calendar modes switch in place and month selection opens day', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(initialIndex: 0)),
    );

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(find.text('24:00'), findsOneWidget);
    expect(find.textContaining('07:30 - 09:30 - Phòng K.P206'), findsOneWidget);
    await tester.tap(find.text('Tuần'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);
    await tester.tap(find.text('16').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngày'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Thứ sáu, 16/10'), findsOneWidget);
    expect(find.text('Chưa có lịch'), findsOneWidget);

    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);
    await tester.tap(find.text('17').first);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(find.textContaining('Thứ bảy, 17/10'), findsOneWidget);
  });

  testWidgets('Quiz tab opens subjects, exams, and the Part 2 placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(initialIndex: 1)),
    );

    expect(find.byType(QuizHomeScreen), findsOneWidget);
    expect(find.byTooltip('Trợ lý AI'), findsOneWidget);
    expect(QuizService.instance.allSubjects, hasLength(2));
    for (final subject in QuizService.instance.allSubjects) {
      expect(QuizService.instance.examsForSubject(subject.id), hasLength(3));
      for (final exam in QuizService.instance.examsForSubject(subject.id)) {
        expect(exam.questions, hasLength(10));
      }
    }

    await tester.tap(find.text('Triết học').first);
    await tester.pumpAndSettle();
    expect(find.byType(SubjectQuizScreen), findsOneWidget);
    expect(find.text('Chung'), findsOneWidget);
    expect(find.text('Đề'), findsOneWidget);
    expect(find.text('Câu sai'), findsOneWidget);

    await tester.tap(find.text('Câu sai'));
    await tester.pumpAndSettle();
    expect(find.textContaining('câu cần ôn lại'), findsOneWidget);

    await tester.tap(find.text('Đề'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đề 1 - Chương 1').first);
    await tester.pumpAndSettle();
    expect(find.byType(ExamDetailScreen), findsOneWidget);
    await tester.tap(find.text('Làm ngay!'));
    await tester.pumpAndSettle();
    expect(find.text('Làm bài sẽ có trong phần tiếp theo.'), findsOneWidget);
  });

  testWidgets('stats routes keep the shell visible and switch periods', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(initialIndex: 3)),
    );

    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Mục tiêu và chuỗi học'), findsOneWidget);
    await tester.tap(find.text('Thống kê học tập'));
    await tester.pumpAndSettle();
    expect(find.text('14h 20p'), findsOneWidget);
    expect(find.byTooltip('Tài liệu'), findsOneWidget);

    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();
    expect(find.text('38h 10p'), findsOneWidget);
    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết ngày học'), findsOneWidget);
    expect(find.text('2h 05p'), findsOneWidget);
    expect(find.byTooltip('Tài liệu'), findsOneWidget);

    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Học kỳ'));
    await tester.pumpAndSettle();
    expect(find.text('128h'), findsOneWidget);

    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Theo môn học'));
    await tester.tap(find.text('Theo môn học'));
    await tester.pumpAndSettle();
    expect(find.text('Tiến độ từng chương'), findsOneWidget);
    expect(find.text('Xem lộ trình ôn thi'), findsOneWidget);
  });

  testWidgets('stats goals, quiz, flashcards, and exam routes work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(initialIndex: 3)),
    );

    await tester.ensureVisible(find.text('Mục tiêu và chuỗi học'));
    await tester.tap(find.text('Mục tiêu và chuỗi học'));
    await tester.pumpAndSettle();
    expect(find.text('Mục tiêu hôm nay'), findsOneWidget);
    await tester.tap(find.text('Đặt mục tiêu mới'));
    await tester.pumpAndSettle();
    expect(find.text('Mục tiêu học mỗi ngày'), findsOneWidget);
    await tester.tap(find.text('Lưu mục tiêu'));
    await tester.pumpAndSettle();
    expect(find.text('Đặt mục tiêu thành công!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Thống kê quiz'));
    await tester.tap(find.text('Thống kê quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Nguyên nhân trả lời sai'), findsOneWidget);
    await tester.ensureVisible(find.text('Xem thống kê ôn tập flashcard'));
    await tester.tap(find.text('Xem thống kê ôn tập flashcard'));
    await tester.pumpAndSettle();
    expect(find.text('Thẻ đã ôn tập'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Theo môn học'));
    await tester.tap(find.text('Theo môn học'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xem lộ trình ôn thi'));
    await tester.tap(find.text('Xem lộ trình ôn thi'));
    await tester.pumpAndSettle();
    expect(find.text('Tiến độ theo môn'), findsOneWidget);
  });

  testWidgets('weekly report schedules a new Calendar event and closes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(initialIndex: 3),
        routes: {'/calendar/event-form': (context) => const EventFormScreen()},
      ),
    );

    await tester.ensureVisible(find.text('Thống kê tập trung'));
    await tester.tap(find.text('Thống kê tập trung'));
    await tester.pumpAndSettle();
    expect(find.text('Báo cáo tuần'), findsOneWidget);
    await tester.ensureVisible(find.text('Xếp lịch cho tuần sau'));
    await tester.tap(find.text('Xếp lịch cho tuần sau'));
    await tester.pumpAndSettle();
    expect(find.byType(EventFormScreen), findsOneWidget);
    expect(find.text('Thêm lịch trình mới'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();
    expect(find.text('Báo cáo tuần'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    expect(find.text('Thống kê'), findsOneWidget);
  });

  testWidgets('calendar can add edit and delete an event', (
    WidgetTester tester,
  ) async {
    final service = CalendarService.instance;
    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(initialIndex: 0),
        routes: {
          '/calendar/event-form': (context) => EventFormScreen(
            event: ModalRoute.of(context)?.settings.arguments as CalendarEvent?,
          ),
          '/calendar/event-detail': (context) => EventDetailScreen(
            eventId: ModalRoute.of(context)!.settings.arguments as String,
          ),
        },
      ),
    );

    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.byType(EventFormScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Lập lịch kiểm tra');
    await tester.enterText(find.byType(TextField).at(1), 'Kiểm tra');
    await tester.pump();
    await tester.ensureVisible(find.text('Xác nhận'));
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận thêm lịch?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmDialog),
        matching: find.text('Thêm'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    final created = service.events.firstWhere(
      (event) => event.title == 'Lập lịch kiểm tra',
    );
    expect(find.byType(CalendarScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Lập lịch kiểm tra'));
    await tester.tap(find.text('Lập lịch kiểm tra'));
    await tester.pumpAndSettle();
    expect(find.byType(EventDetailScreen), findsOneWidget);
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Kiểm tra giữa kỳ');
    await tester.pump();
    await tester.ensureVisible(find.text('Xác nhận'));
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmDialog),
        matching: find.text('Đồng ý'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(service.eventById(created.id)?.title, 'Kiểm tra giữa kỳ');

    await tester.ensureVisible(find.text('Xóa buổi học'));
    await tester.tap(find.text('Xóa buổi học'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmDialog),
        matching: find.text('Xóa'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(service.eventById(created.id), isNull);
    expect(find.byType(CalendarScreen), findsOneWidget);
  });
}
