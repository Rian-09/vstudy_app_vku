import {
  BookOpenCheck,
  FileStack,
  ShieldCheck,
  Users,
} from 'lucide-react';

const sections = [
  {
    title: 'Người dùng',
    description: 'Quản lý hồ sơ và quyền truy cập.',
    icon: Users,
    color: 'bg-brand-lavender text-brand-purple',
  },
  {
    title: 'Quiz',
    description: 'Tạo ngân hàng câu hỏi cho sinh viên.',
    icon: BookOpenCheck,
    color: 'bg-brand-lime/30 text-brand-purple',
  },
  {
    title: 'Tài liệu',
    description: 'Tổ chức và chia sẻ học liệu VKU.',
    icon: FileStack,
    color: 'bg-purple-50 text-brand-purple',
  },
];

export function DashboardPage() {
  return (
    <div className="space-y-7">
      <section className="overflow-hidden rounded-3xl bg-gradient-to-br from-brand-purple via-[#7e70d2] to-[#a69be7] p-6 text-white shadow-panel sm:p-9">
        <div className="flex flex-col justify-between gap-6 sm:flex-row sm:items-end">
          <div className="max-w-2xl">
            <p className="mb-3 inline-flex items-center gap-2 rounded-full bg-white/15 px-3 py-1 text-xs font-semibold text-brand-lime">
              <ShieldCheck size={14} />
              Không gian quản trị
            </p>
            <h1 className="text-2xl font-bold sm:text-3xl">
              Chào mừng đến với V-STUDY Admin
            </h1>
            <p className="mt-3 text-sm leading-6 text-white/75">
              Nền tảng quản lý tài khoản, học liệu và ngân hàng quiz dành cho
              cộng đồng sinh viên VKU.
            </p>
          </div>
          <div className="hidden h-24 w-24 shrink-0 place-items-center rounded-3xl bg-brand-lime text-brand-purple sm:grid">
            <BookOpenCheck size={42} />
          </div>
        </div>
      </section>

      <section aria-labelledby="admin-modules-heading">
        <div className="mb-4">
          <h2
            id="admin-modules-heading"
            className="text-lg font-bold text-brand-ink"
          >
            Khu vực quản lý
          </h2>
          <p className="mt-1 text-sm text-brand-muted">
            Các module sẽ được triển khai theo từng bước đã thống nhất.
          </p>
        </div>
        <div className="grid gap-4 lg:grid-cols-3">
          {sections.map(({ title, description, icon: Icon, color }) => (
            <article
              key={title}
              className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm"
            >
              <div
                className={`mb-4 grid h-11 w-11 place-items-center rounded-xl ${color}`}
              >
                <Icon size={21} />
              </div>
              <h3 className="font-bold text-brand-ink">{title}</h3>
              <p className="mt-1 text-sm leading-6 text-brand-muted">
                {description}
              </p>
            </article>
          ))}
        </div>
      </section>

      <p className="text-xs text-slate-400">
        Thống kê sẽ hiển thị sau khi kết nối dữ liệu quản trị.
      </p>
    </div>
  );
}
