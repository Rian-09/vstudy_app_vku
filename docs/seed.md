# Seed dữ liệu Supabase

Chạy sau hai migration schema:

1. Tạo và xác minh `admin@vku.udn.vn` trong Supabase Authentication.
2. Chạy lại [202611070001_create_profiles.sql](../supabase/migrations/202611070001_create_profiles.sql)
   một lần để cập nhật trigger bảo vệ profile (nếu migration cũ đã chạy).
3. Chạy `supabase/seed/001_content_seed.sql` trong SQL Editor bằng tài khoản
   database owner.

Script sẽ nâng tài khoản trên thành `ADMIN`, tạo hai môn `TRIET` và `PLDC`,
tạo quiz tương ứng và thêm 30 câu hỏi cho mỗi môn. Mỗi câu có bốn lựa chọn,
đáp án đúng và phần giải thích. Script không chứa mật khẩu admin.
