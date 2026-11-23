import { ShieldX } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from '../../components/ui/button';

export function AccessDeniedPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-brand-surface px-4">
      <section className="w-full max-w-md rounded-3xl bg-white p-8 text-center shadow-panel">
        <div className="mx-auto mb-5 grid h-14 w-14 place-items-center rounded-2xl bg-red-50 text-brand-red">
          <ShieldX size={28} />
        </div>
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-brand-red">
          Access denied
        </p>
        <h1 className="mt-3 text-2xl font-bold text-brand-ink">
          Tài khoản không có quyền quản trị
        </h1>
        <p className="mt-3 text-sm leading-6 text-brand-muted">
          Phiên đăng nhập đã được kết thúc. Vui lòng liên hệ quản trị viên nếu
          bạn cần quyền truy cập.
        </p>
        <Button asChild variant="outline" className="mt-7">
          <Link to="/login">Quay lại đăng nhập</Link>
        </Button>
      </section>
    </main>
  );
}
