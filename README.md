# V-Study

Ứng dụng hỗ trợ học tập dành cho sinh viên, viết bằng **Flutter**. Giao diện được chuyển từ thiết kế **Figma** sang code bằng **Figma MCP + GitHub Copilot Agent** trong VS Code.

> Thiết kế: [Figma – UX/UI](https://www.figma.com/design/7iOrcdRy7hCTBoiEnxOvh2/UX-UI) (trang `Do_An`)

---

## Mục lục

1. [Tính năng](#tính-năng)
2. [Công nghệ](#công-nghệ)
3. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
4. [Cài đặt và chạy](#cài-đặt-và-chạy)
5. [Tài khoản demo](#tài-khoản-demo)
6. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
7. [Luồng màn hình](#luồng-màn-hình)
8. [Chuyển Figma sang code](#chuyển-figma-sang-code)
9. [Trạng thái triển khai](#trạng-thái-triển-khai)
10. [Lưu ý](#lưu-ý)

---

## Tính năng

| Nhóm | Mô tả |
|------|-------|
| **Màn hình chờ** | Animation logo, chữ "V - Study" xuất hiện rồi chuyển sang đăng nhập |
| **Đăng nhập / Đăng ký** | Form kiểm tra dữ liệu, nút chỉ sáng khi hợp lệ, ẩn/hiện mật khẩu, tiếp tục với Google (giao diện) |
| **Trang chủ** | Lời chào, tiến độ học trong ngày, truy cập nhanh Quiz/Tài liệu, gợi ý AI, biểu đồ tuần, deadline sắp đến |
| **Hồ sơ** | Thông tin cá nhân, chỉ số học tập, môn học, cài đặt, sửa hồ sơ, đăng xuất |
| **Tài liệu** | Tìm kiếm, lọc theo môn, xem tài liệu, tải xuống (giả lập), thư viện đã lưu |
| **Lịch** | Xem theo Ngày / Tuần / Tháng, thêm, xem chi tiết, sửa, xóa lịch |
| **Thống kê** | Thống kê học tập (Tuần / Tháng / Học kỳ), theo môn, chi tiết ngày, mục tiêu, báo cáo tuần, phân tích lỗi sai, tiến độ ôn thi |
| **Quiz** | Danh sách môn và đề, làm bài trắc nghiệm, kiểm tra đáp án, nộp bài, kết quả, xem lại, biểu đồ |
| **Trợ lý AI** | Chat hỏi đáp, tóm tắt tài liệu, tạo đề ôn, lộ trình ôn tập (dữ liệu giả lập) |

## Công nghệ

- **Flutter / Dart** (Material)
- **Điều hướng:** `go_router` hoặc `Navigator` (named routes)
- **Quản lý trạng thái:** `ChangeNotifier` / `ValueNotifier` đơn giản
- **Biểu đồ:** vẽ bằng `CustomPainter` (không cần package ngoài)
- **Dữ liệu:** mock data trong bộ nhớ, chưa có backend
- **Thiết kế → code:** Figma Dev Mode, Figma MCP, VS Code, GitHub Copilot (Agent)

## Yêu cầu hệ thống

- Flutter SDK (kiểm tra bằng `flutter doctor`)
- VS Code hoặc Android Studio
- Chrome (để chạy bản web) hoặc giả lập / thiết bị thật
- Git

## Cài đặt và chạy

```bash
# 1. Lấy mã nguồn
git clone <đường-dẫn-repo>
cd flutter_application_1

# 2. Cài thư viện
flutter pub get

# 3. Chạy
flutter run -d chrome     # trình duyệt
flutter run               # thiết bị / giả lập đang kết nối
```

Kiểm tra mã nguồn:

```bash
flutter analyze
flutter test
```

## Tài khoản demo

Ứng dụng dùng dữ liệu đăng nhập giả để kiểm thử:

| Trường | Giá trị |
|--------|---------|
| Email | `people@gmail.com` |
| Mật khẩu | `admin123` |
| Tên hiển thị | Tom |

Tài khoản tạo ở màn **Đăng ký** được lưu trong bộ nhớ và mất khi tắt ứng dụng.

## Cấu trúc thư mục

```text
lib/
├── main.dart
├── router/                  # khai báo route
├── theme/                   # màu, chữ, spacing, bo góc (từ Figma)
├── widgets/                 # widget dùng chung: nút, ô nhập, dialog, popup...
├── models/                  # model dữ liệu (document, calendar_event, quiz...)
├── services/                # AuthService, CalendarService, QuizService... (mock)
└── screens/
    ├── main_shell.dart      # khung chứa thanh điều hướng dưới + nút AI nổi
    ├── splash/
    ├── auth/                # login, register
    ├── home/
    ├── profile/
    ├── documents/
    ├── calendar/
    ├── stats/
    ├── quiz/
    └── ai/
assets/
├── images/                  # logo, avatar, minh họa xuất từ Figma
└── fonts/
docs/
└── Huong_dan_Figma_sang_Flutter.docx
```

> Cấu trúc trên là bố cục đề xuất khi sinh code. Nếu thư mục thực tế khác, hãy cập nhật lại mục này.

## Luồng màn hình

```text
Splash ─► Đăng nhập ◄──► Đăng ký
              │
              ▼
        MainShell (thanh điều hướng 5 mục + nút AI nổi)
        ├── Lịch ─► Thêm / Chi tiết / Sửa
        ├── Tài liệu ─► Xem tài liệu ─► Tải xuống ─► Thư viện
        ├── Trang chủ ─► (bấm avatar) Hồ sơ ─► Sửa hồ sơ / Đăng xuất
        ├── Thống kê ─► Học tập / Theo môn / Chi tiết ngày / Báo cáo...
        └── Quiz ─► Môn học ─► Chi tiết đề ─► Làm bài ─► Kết quả ─► Xem lại / Biểu đồ

Nút AI nổi ─► Trợ lý ─► Chat / Tóm tắt / Tạo đề ôn / Lộ trình
```

## Chuyển Figma sang code

Dự án có gần 200 frame Figma nên không dựng từng màn bằng tay. Quy trình đã dùng:

1. **Kết nối Figma MCP** trong VS Code bằng `.vscode/mcp.json`:

   ```json
   {
     "servers": {
       "figma": {
         "type": "http",
         "url": "https://mcp.figma.com/mcp"
       }
     }
   }
   ```

   Bấm **Start**, đăng nhập Figma, kiểm tra trạng thái `Running | 43 tools`.
2. **Dựng nền tảng một lần:** theme, widget dùng chung, router.
3. **Phân loại frame:** frame nào là màn thật, frame nào chỉ là trạng thái (rỗng/đã nhập, popup, lỗi, thành công).
4. **Gom link** (Figma: chuột phải frame → *Copy link to selection*), mỗi lượt 1 đến 5 frame.
5. **Viết prompt** theo mẫu: bối cảnh, danh sách frame, `BUILD`, `FLOW`, `RULES`; dùng Copilot Chat ở chế độ **Agent**.
6. **Chạy thử và commit** sau mỗi nhóm màn hình.

Hướng dẫn đầy đủ, có hình minh chứng và prompt mẫu: [`docs/Huong_dan_Figma_sang_Flutter.docx`](docs/Huong_dan_Figma_sang_Flutter.docx).

## Trạng thái triển khai

Đánh dấu theo tiến độ thực tế của dự án.

- [x] Màn hình chờ
- [x] Đăng nhập / Đăng ký (dữ liệu giả)
- [x] Trang chủ + thanh điều hướng + nút AI nổi
- [ ] Hồ sơ
- [ ] Tài liệu
- [ ] Lịch
- [ ] Thống kê
- [ ] Quiz
- [ ] Trợ lý AI
- [ ] Kết nối backend / API thật
- [ ] Chế độ tối

## Lưu ý

- Toàn bộ dữ liệu hiện là **dữ liệu giả**; chưa lưu trữ lâu dài và chưa có máy chủ.
- Tải tài liệu, trợ lý AI, đăng nhập Google chỉ là **giả lập giao diện**.
- Ảnh, logo, icon xuất từ Figma đặt trong `assets/images/` và phải khai báo trong `pubspec.yaml`.
- Chữ tiếng Việt cần font hỗ trợ dấu (ví dụ Be Vietnam Pro, Inter).
- Mã nguồn do AI sinh ra cần được đọc và kiểm tra trước khi dùng cho sản phẩm thật.
