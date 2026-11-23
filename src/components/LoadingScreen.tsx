export function LoadingScreen() {
  return (
    <main
      className="grid min-h-screen place-items-center bg-brand-surface"
      role="status"
      aria-live="polite"
    >
      <div className="flex items-center gap-3 rounded-2xl bg-white px-5 py-4 shadow-panel">
        <span className="h-5 w-5 animate-spin rounded-full border-2 border-brand-yellow border-t-brand-blue" />
        <span className="text-sm font-medium text-brand-ink">
          Đang kiểm tra phiên đăng nhập...
        </span>
      </div>
    </main>
  );
}
