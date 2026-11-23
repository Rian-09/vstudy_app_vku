import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { lazy, Suspense, useEffect, useState } from 'react';
import { BrowserRouter, Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { Toaster } from 'sonner';
import { AppLayout } from './components/AppLayout';
import { AccessDeniedPage } from './features/auth/AccessDeniedPage';
import { AuthProvider, useAuth } from './features/auth/AuthProvider';
import { ProtectedRoute, PublicOnlyRoute } from './features/auth/ProtectedRoute';
import { LoadingScreen } from './components/LoadingScreen';

const LoginPage = lazy(() =>
  import('./features/auth/LoginPage').then((module) => ({
    default: module.LoginPage,
  })),
);
const DashboardPage = lazy(() =>
  import('./features/dashboard/DashboardPage').then((module) => ({
    default: module.DashboardPage,
  })),
);
const AccountManagementPage = lazy(() =>
  import('./features/users/AccountManagementPage').then((module) => ({
    default: module.AccountManagementPage,
  })),
);
const CatalogManagementPage = lazy(() =>
  import('./features/catalog/CatalogManagementPage').then((module) => ({
    default: module.CatalogManagementPage,
  })),
);
const DocumentManagementPage = lazy(() =>
  import('./features/documents/DocumentManagementPage').then((module) => ({
    default: module.DocumentManagementPage,
  })),
);
const QuizManagementPage = lazy(() =>
  import('./features/quizzes/QuizManagementPage').then((module) => ({
    default: module.QuizManagementPage,
  })),
);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const adminPages = [
  { path: '/', element: <DashboardPage /> },
  { path: '/quizzes', element: <QuizManagementPage /> },
  { path: '/documents', element: <DocumentManagementPage /> },
  { path: '/catalog', element: <CatalogManagementPage /> },
  { path: '/users', element: <AccountManagementPage /> },
  { path: '/stats', element: <ModulePlaceholder title="Thống kê" /> },
];

function KeepAliveAdminPages() {
  const { pathname } = useLocation();
  const normalizedPath = pathname.replace(/\/+$/, '') || '/';
  const isKnownPath = adminPages.some((page) => page.path === normalizedPath);
  const [mountedPaths, setMountedPaths] = useState(
    () => new Set([isKnownPath ? normalizedPath : '/']),
  );

  useEffect(() => {
    if (!isKnownPath) return;
    setMountedPaths((paths) => new Set(paths).add(normalizedPath));
  }, [isKnownPath, normalizedPath]);

  if (!isKnownPath) return <Navigate to="/" replace />;

  return (
    <>
      {adminPages
        .filter((page) => mountedPaths.has(page.path))
        .map((page) => (
          <div key={page.path} hidden={page.path !== normalizedPath}>
            {page.element}
          </div>
        ))}
    </>
  );
}

function AuthErrorPage() {
  const { error } = useAuth();
  return (
    <main className="grid min-h-screen place-items-center bg-brand-surface px-4">
      <section className="max-w-lg rounded-2xl bg-white p-7 shadow-panel">
        <h1 className="text-xl font-bold text-brand-ink">
          Không thể xác minh phiên đăng nhập
        </h1>
        <p role="alert" className="mt-3 text-sm leading-6 text-brand-red">
          {error ?? 'Vui lòng thử lại sau.'}
        </p>
        <a
          className="mt-5 inline-flex text-sm font-semibold text-brand-blue underline"
          href="/login"
        >
          Quay lại đăng nhập
        </a>
      </section>
    </main>
  );
}

function AppRoutes() {
  const { status } = useAuth();
  if (status === 'error') return <AuthErrorPage />;
  if (status === 'loading') return <LoadingScreen />;

  return (
    <Suspense fallback={<LoadingScreen />}>
      <Routes>
        <Route element={<PublicOnlyRoute />}>
          <Route path="/login" element={<LoginPage />} />
        </Route>
        <Route path="/access-denied" element={<AccessDeniedPage />} />
        <Route element={<ProtectedRoute />}>
          <Route element={<AppLayout />}>
            <Route path="*" element={<KeepAliveAdminPages />} />
          </Route>
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Suspense>
  );
}

function ModulePlaceholder({ title }: { title: string }) {
  return (
    <section className="rounded-2xl border border-slate-100 bg-white p-7 shadow-sm">
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
        Sẽ triển khai ở bước tiếp theo
      </p>
      <h1 className="mt-2 text-2xl font-bold text-brand-ink">{title}</h1>
      <p className="mt-2 text-sm text-brand-muted">
        Module này chưa được bật trong bước scaffold.
      </p>
    </section>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <AppRoutes />
          <Toaster position="top-right" richColors />
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  );
}
