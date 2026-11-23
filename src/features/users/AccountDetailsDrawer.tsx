import { useQuery } from '@tanstack/react-query';
import { X } from 'lucide-react';
import { fetchAccountActivity } from './accountService';
import type { AdminAccount } from './types';

interface AccountDetailsDrawerProps {
  account: AdminAccount;
  onClose: () => void;
}

function formatDate(value: string | null) {
  if (!value) return 'Chưa có hoạt động được ghi nhận';
  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

export function AccountDetailsDrawer({
  account,
  onClose,
}: AccountDetailsDrawerProps) {
  const activityQuery = useQuery({
    queryKey: ['account-activity', account.id],
    queryFn: () => fetchAccountActivity(account.id),
  });

  return (
    <div
      className="fixed inset-0 z-30 flex justify-end bg-slate-950/35"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) onClose();
      }}
    >
      <aside
        role="dialog"
        aria-modal="true"
        aria-labelledby="account-details-title"
        className="flex h-full w-full max-w-lg flex-col bg-white shadow-2xl"
      >
        <header className="flex items-start justify-between border-b border-slate-100 p-6">
          <div className="min-w-0">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
              Chi tiết tài khoản
            </p>
            <h2
              id="account-details-title"
              className="mt-2 truncate text-xl font-bold text-brand-ink"
            >
              {account.full_name || 'Chưa cập nhật tên'}
            </h2>
            <p className="mt-1 break-all text-sm text-brand-muted">
              {account.email}
            </p>
          </div>
          <button
            type="button"
            className="rounded-lg p-2 text-slate-500 hover:bg-slate-100"
            aria-label="Đóng chi tiết"
            onClick={onClose}
          >
            <X size={20} />
          </button>
        </header>

        <div className="flex-1 space-y-6 overflow-y-auto p-6">
          <dl className="grid grid-cols-2 gap-3">
            <DetailItem
              label="Vai trò"
              value={account.role === 'ADMIN' ? 'Quản trị viên' : 'Sinh viên'}
            />
            <DetailItem
              label="Trạng thái"
              value={account.is_locked ? 'Đã khóa' : 'Đang hoạt động'}
            />
            <DetailItem
              label="Ngày đăng ký"
              value={formatDate(account.created_at)}
            />
            <DetailItem
              label="Lần hoạt động gần nhất"
              value={
                activityQuery.isPending
                  ? 'Đang tải...'
                  : formatDate(
                      activityQuery.data?.last_recorded_activity ?? null,
                    )
              }
            />
          </dl>

          {activityQuery.isError && (
            <div
              role="alert"
              className="rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800"
            >
              Không thể tải hoạt động tài khoản. Hãy kiểm tra migration
              `202611230001_admin_account_audit.sql` đã được áp dụng chưa.
            </div>
          )}

          {activityQuery.data && (
            <section>
              <h3 className="mb-3 text-sm font-bold text-brand-ink">
                Hoạt động ghi nhận
              </h3>
              <div className="grid grid-cols-2 gap-3">
                <DetailItem
                  label="Lượt làm quiz"
                  value={activityQuery.data.quiz_attempt_count.toLocaleString(
                    'vi-VN',
                  )}
                />
                <DetailItem
                  label="Thời gian học đã ghi nhận"
                  value={`${activityQuery.data.recorded_study_minutes.toLocaleString('vi-VN')} phút`}
                />
              </div>
              <p className="mt-3 text-xs leading-5 text-brand-muted">
                Thời gian này chỉ cộng từ hoạt động học trong
                `study_sessions`; chưa phải tổng thời gian app đang mở.
              </p>
            </section>
          )}
        </div>
      </aside>
    </div>
  );
}

function DetailItem({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-slate-50 p-4">
      <dt className="text-xs font-medium text-brand-muted">{label}</dt>
      <dd className="mt-1 break-words text-sm font-semibold text-brand-ink">
        {value}
      </dd>
    </div>
  );
}
