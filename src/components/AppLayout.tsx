import {
  BookOpenCheck,
  ChartNoAxesCombined,
  FileStack,
  GraduationCap,
  LayoutDashboard,
  ListTree,
  LogOut,
  ShieldCheck,
  Users,
} from 'lucide-react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import { Button } from './ui/button';
import { useAuth } from '../features/auth/AuthProvider';
import { getErrorMessage } from '../lib/errors';

const navigation = [
  { to: '/', label: 'Tổng quan', icon: LayoutDashboard, end: true },
  { to: '/quizzes', label: 'Quản lý quiz', icon: BookOpenCheck },
  { to: '/documents', label: 'Tài liệu', icon: FileStack },
  { to: '/catalog', label: 'Ngành & môn học', icon: ListTree },
  { to: '/users', label: 'Tài khoản', icon: Users },
  { to: '/stats', label: 'Thống kê', icon: ChartNoAxesCombined },
];

export function AppLayout() {
  const { profile, logout } = useAuth();
  const navigate = useNavigate();
  const [logoutError, setLogoutError] = useState<string | null>(null);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleLogout = async () => {
    setLogoutError(null);
    setIsLoggingOut(true);
    try {
      await logout();
      navigate('/login', { replace: true });
    } catch (error) {
      setLogoutError(getErrorMessage(error));
    } finally {
      setIsLoggingOut(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-surface md:grid md:grid-cols-[252px_minmax(0,1fr)]">
      <aside className="flex flex-col border-b border-slate-200 bg-white md:sticky md:top-0 md:h-screen md:border-b-0 md:border-r">
        <div className="flex items-center gap-3 px-5 py-5">
          <div className="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-brand-purple to-[#988ae4] text-white shadow-sm">
            <GraduationCap size={23} />
          </div>
          <div>
            <p className="font-extrabold tracking-wide text-brand-blue">V-STUDY</p>
            <p className="text-xs text-brand-muted">Admin panel</p>
          </div>
        </div>
        <nav
          aria-label="Điều hướng chính"
          className="flex gap-1 overflow-x-auto px-3 pb-3 md:flex-1 md:flex-col md:overflow-visible md:px-3"
        >
          <p className="hidden px-3 pb-2 pt-5 text-[11px] font-bold uppercase tracking-[0.16em] text-slate-400 md:block">
            Không gian quản trị
          </p>
          {navigation.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) =>
                `flex shrink-0 items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition ${
                  isActive
                    ? 'bg-brand-lavender text-brand-purple'
                    : 'text-brand-muted hover:bg-brand-lavender/60 hover:text-brand-ink'
                }`
              }
            >
              <Icon size={18} />
              {label}
            </NavLink>
          ))}
        </nav>
        <div className="hidden border-t border-slate-100 p-4 md:block">
          <div className="flex items-center gap-3 rounded-xl bg-brand-lavender/70 p-3">
            <div className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-brand-purple text-sm font-bold text-white">
              {(profile?.full_name || profile?.email || 'A')
                .slice(0, 1)
                .toUpperCase()}
            </div>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-brand-ink">
                {profile?.full_name || 'Quản trị viên'}
              </p>
              <p className="truncate text-xs text-brand-muted">
                {profile?.email}
              </p>
            </div>
            <ShieldCheck size={17} className="shrink-0 text-brand-blue" />
          </div>
          {logoutError && (
            <p role="alert" className="mt-2 text-xs text-brand-red">
              {logoutError}
            </p>
          )}
          <Button
            variant="ghost"
            size="sm"
            className="mt-2 w-full justify-start"
            onClick={handleLogout}
            disabled={isLoggingOut}
          >
            <LogOut size={16} />
            {isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'}
          </Button>
        </div>
      </aside>

      <div className="min-w-0">
        <header className="sticky top-0 z-10 flex h-[68px] items-center justify-between border-b border-brand-purple/10 bg-gradient-to-r from-brand-lavender/90 via-white/95 to-white/95 px-5 backdrop-blur sm:px-8">
          <div>
            <p className="text-sm font-semibold text-brand-ink">
              Hệ thống quản trị V-STUDY
            </p>
            <p className="hidden text-xs text-brand-muted sm:block">
              Đại học CNTT và Truyền thông Việt - Hàn
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span className="hidden rounded-full bg-brand-lime/30 px-3 py-1 text-xs font-semibold text-brand-purple sm:inline-flex">
              Đã xác thực admin
            </span>
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden"
              aria-label="Đăng xuất"
              onClick={handleLogout}
              disabled={isLoggingOut}
            >
              <LogOut size={18} />
            </Button>
          </div>
        </header>
        <main className="mx-auto w-full max-w-[1440px] p-5 sm:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
