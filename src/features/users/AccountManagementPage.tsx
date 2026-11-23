import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  ChevronLeft,
  ChevronRight,
  LockKeyhole,
  Search,
  Shield,
  UnlockKeyhole,
  UserRound,
} from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { useAuth } from '../auth/AuthProvider';
import {
  fetchAccounts,
  updateAccountAccess,
} from './accountService';
import { AccountDetailsDrawer } from './AccountDetailsDrawer';
import type {
  AccountRole,
  AccountStatus,
  AdminAccount,
} from './types';

const PAGE_SIZE = 10;

type PendingAction = {
  account: AdminAccount;
  role: AccountRole;
  isLocked: boolean;
  title: string;
  message: string;
  confirmLabel: string;
  destructive: boolean;
};

function formatDate(value: string) {
  return new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium' }).format(
    new Date(value),
  );
}

export function AccountManagementPage() {
  const { profile } = useAuth();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');
  const [role, setRole] = useState<AccountRole | 'all'>('all');
  const [status, setStatus] = useState<AccountStatus | 'all'>('all');
  const [selectedAccount, setSelectedAccount] = useState<AdminAccount | null>(
    null,
  );
  const [pendingAction, setPendingAction] = useState<PendingAction | null>(null);
  const [debouncedSearch, setDebouncedSearch] = useState('');

  useEffect(() => {
    const timer = window.setTimeout(
      () => setDebouncedSearch(search.trim()),
      250,
    );
    return () => window.clearTimeout(timer);
  }, [search]);

  const accountsQuery = useQuery({
    queryKey: ['admin-accounts', page, debouncedSearch, role, status],
    queryFn: () =>
      fetchAccounts({
        page,
        pageSize: PAGE_SIZE,
        search: debouncedSearch,
        role,
        status,
      }),
  });

  const mutation = useMutation({
    mutationFn: (action: PendingAction) =>
      updateAccountAccess(action.account.id, action.role, action.isLocked),
    onSuccess: async () => {
      toast.success('Đã cập nhật tài khoản và ghi audit log.');
      setPendingAction(null);
      await queryClient.invalidateQueries({ queryKey: ['admin-accounts'] });
      await queryClient.invalidateQueries({ queryKey: ['account-activity'] });
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Không thể cập nhật tài khoản.',
      );
    },
  });

  const total = accountsQuery.data?.total ?? 0;
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE));
  const accounts = accountsQuery.data?.accounts ?? [];

  const resetPage = () => setPage(0);
  const beginRoleChange = (account: AdminAccount) => {
    const roleToSet = account.role === 'ADMIN' ? 'STUDENT' : 'ADMIN';
    setPendingAction({
      account,
      role: roleToSet,
      isLocked: account.is_locked,
      title: roleToSet === 'ADMIN' ? 'Cấp quyền quản trị?' : 'Gỡ quyền quản trị?',
      message:
        roleToSet === 'ADMIN'
          ? `Cấp quyền ADMIN cho ${account.email}? Tài khoản sẽ có quyền quản lý dữ liệu trong panel.`
          : `Chuyển ${account.email} về vai trò sinh viên?`,
      confirmLabel: roleToSet === 'ADMIN' ? 'Cấp quyền' : 'Gỡ quyền',
      destructive: roleToSet === 'STUDENT',
    });
  };
  const beginLockChange = (account: AdminAccount) => {
    const lock = !account.is_locked;
    setPendingAction({
      account,
      role: account.role,
      isLocked: lock,
      title: lock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?',
      message: lock
        ? `Khóa ${account.email}? Quyền truy cập sẽ bị giới hạn sau khi xác nhận.`
        : `Mở khóa ${account.email}?`,
      confirmLabel: lock ? 'Khóa tài khoản' : 'Mở khóa',
      destructive: lock,
    });
  };

  return (
    <div className="space-y-6">
      <div>
        <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
          Quản trị người dùng
        </p>
        <h1 className="mt-2 text-2xl font-bold text-brand-ink">
          Quản lý tài khoản
        </h1>
        <p className="mt-1 text-sm text-brand-muted">
          Tìm kiếm hồ sơ VKU, phân quyền và quản lý trạng thái truy cập.
        </p>
      </div>

      <section className="rounded-2xl border border-slate-100 bg-white p-4 shadow-sm sm:p-5">
        <div className="grid gap-3 lg:grid-cols-[minmax(240px,1fr)_180px_180px]">
          <label className="relative block">
            <Search
              size={17}
              className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"
            />
            <Input
              value={search}
              onChange={(event) => {
                setSearch(event.target.value);
                resetPage();
              }}
              placeholder="Tìm theo tên hoặc email..."
              className="pl-10"
              aria-label="Tìm theo tên hoặc email"
            />
          </label>
          <select
            value={role}
            onChange={(event) => {
              setRole(event.target.value as AccountRole | 'all');
              resetPage();
            }}
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Lọc vai trò"
          >
            <option value="all">Tất cả vai trò</option>
            <option value="STUDENT">Sinh viên</option>
            <option value="ADMIN">Quản trị viên</option>
          </select>
          <select
            value={status}
            onChange={(event) => {
              setStatus(event.target.value as AccountStatus | 'all');
              resetPage();
            }}
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Lọc trạng thái"
          >
            <option value="all">Mọi trạng thái</option>
            <option value="active">Đang hoạt động</option>
            <option value="locked">Đã khóa</option>
          </select>
        </div>

        {accountsQuery.isPending ? (
          <div className="mt-5 space-y-3" aria-label="Đang tải tài khoản">
            {Array.from({ length: 5 }, (_, index) => (
              <div
                key={index}
                className="h-14 animate-pulse rounded-xl bg-slate-100"
              />
            ))}
          </div>
        ) : accountsQuery.isError ? (
          <div
            role="alert"
            className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800"
          >
            Không thể tải danh sách tài khoản.{' '}
            {accountsQuery.error instanceof Error
              ? accountsQuery.error.message
              : 'Vui lòng thử lại.'}
            <Button
              variant="outline"
              size="sm"
              className="ml-3"
              onClick={() => void accountsQuery.refetch()}
            >
              Thử lại
            </Button>
          </div>
        ) : (
          <>
            <div className="mt-5 overflow-x-auto">
              <table className="w-full min-w-[850px] border-collapse text-left">
                <thead>
                  <tr className="border-b border-slate-100 text-xs font-semibold uppercase tracking-wide text-slate-400">
                    <th className="px-3 py-3">Người dùng</th>
                    <th className="px-3 py-3">Vai trò</th>
                    <th className="px-3 py-3">Trạng thái</th>
                    <th className="px-3 py-3">Ngày đăng ký</th>
                    <th className="px-3 py-3 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  {accounts.map((account) => {
                    const isSelf = account.id === profile?.id;
                    return (
                      <tr
                        key={account.id}
                        className="border-b border-slate-50 last:border-0 hover:bg-slate-50/70"
                      >
                        <td className="px-3 py-3.5">
                          <div className="flex min-w-0 items-center gap-3">
                            <span className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-blue-50 text-brand-blue">
                              <UserRound size={17} />
                            </span>
                            <span className="min-w-0">
                              <span className="block truncate text-sm font-semibold text-brand-ink">
                                {account.full_name || 'Chưa cập nhật tên'}
                                {isSelf && (
                                  <span className="ml-2 text-xs font-medium text-brand-blue">
                                    (Bạn)
                                  </span>
                                )}
                              </span>
                              <span className="block truncate text-xs text-brand-muted">
                                {account.email}
                              </span>
                            </span>
                          </div>
                        </td>
                        <td className="px-3 py-3.5">
                          <span
                            className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ${
                              account.role === 'ADMIN'
                                ? 'bg-blue-50 text-brand-blue'
                                : 'bg-slate-100 text-slate-600'
                            }`}
                          >
                            {account.role === 'ADMIN' && <Shield size={13} />}
                            {account.role === 'ADMIN'
                              ? 'Quản trị viên'
                              : 'Sinh viên'}
                          </span>
                        </td>
                        <td className="px-3 py-3.5">
                          <span
                            className={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${
                              account.is_locked
                                ? 'bg-red-50 text-brand-red'
                                : 'bg-emerald-50 text-emerald-700'
                            }`}
                          >
                            {account.is_locked ? 'Đã khóa' : 'Hoạt động'}
                          </span>
                        </td>
                        <td className="px-3 py-3.5 text-sm text-brand-muted">
                          {formatDate(account.created_at)}
                        </td>
                        <td className="px-3 py-3.5">
                          <div className="flex justify-end gap-1">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => setSelectedAccount(account)}
                            >
                              Chi tiết
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              aria-label={
                                account.is_locked
                                  ? `Mở khóa ${account.email}`
                                  : `Khóa ${account.email}`
                              }
                              title={
                                isSelf
                                  ? 'Không thể khóa chính mình'
                                  : account.is_locked
                                    ? 'Mở khóa tài khoản'
                                    : 'Khóa tài khoản'
                              }
                              disabled={isSelf}
                              onClick={() => beginLockChange(account)}
                            >
                              {account.is_locked ? (
                                <UnlockKeyhole size={17} />
                              ) : (
                                <LockKeyhole size={17} />
                              )}
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              disabled={isSelf}
                              title={
                                isSelf
                                  ? 'Không thể tự thay đổi vai trò'
                                  : undefined
                              }
                              onClick={() => beginRoleChange(account)}
                            >
                              {account.role === 'ADMIN'
                                ? 'Gỡ admin'
                                : 'Cấp admin'}
                            </Button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                  {accounts.length === 0 && (
                    <tr>
                      <td
                        colSpan={5}
                        className="px-3 py-12 text-center text-sm text-brand-muted"
                      >
                        Không tìm thấy tài khoản phù hợp.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>

            <footer className="mt-4 flex flex-col gap-3 border-t border-slate-100 pt-4 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-xs text-brand-muted">
                {total === 0
                  ? '0 tài khoản'
                  : `${page * PAGE_SIZE + 1}–${Math.min(
                      (page + 1) * PAGE_SIZE,
                      total,
                    )} trong ${total.toLocaleString('vi-VN')} tài khoản`}
              </p>
              <div className="flex items-center justify-end gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  aria-label="Trang trước"
                  disabled={page === 0}
                  onClick={() => setPage((current) => Math.max(0, current - 1))}
                >
                  <ChevronLeft size={16} />
                  Trước
                </Button>
                <span className="min-w-20 text-center text-xs text-brand-muted">
                  Trang {page + 1} / {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  aria-label="Trang sau"
                  disabled={page + 1 >= pageCount}
                  onClick={() =>
                    setPage((current) => Math.min(pageCount - 1, current + 1))
                  }
                >
                  Sau
                  <ChevronRight size={16} />
                </Button>
              </div>
            </footer>
          </>
        )}
      </section>

      {selectedAccount && (
        <AccountDetailsDrawer
          account={selectedAccount}
          onClose={() => setSelectedAccount(null)}
        />
      )}

      {pendingAction && (
        <ConfirmAccountAction
          action={pendingAction}
          isPending={mutation.isPending}
          onCancel={() => setPendingAction(null)}
          onConfirm={() => mutation.mutate(pendingAction)}
        />
      )}
    </div>
  );
}

function ConfirmAccountAction({
  action,
  isPending,
  onCancel,
  onConfirm,
}: {
  action: PendingAction;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  return (
    <div
      className="fixed inset-0 z-40 grid place-items-center bg-slate-950/40 p-4"
      onMouseDown={(event) => {
        if (!isPending && event.target === event.currentTarget) onCancel();
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="confirm-account-action-title"
        className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
      >
        <h2
          id="confirm-account-action-title"
          className="text-lg font-bold text-brand-ink"
        >
          {action.title}
        </h2>
        <p className="mt-2 text-sm leading-6 text-brand-muted">
          {action.message}
        </p>
        <div className="mt-6 flex justify-end gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={onCancel}
            disabled={isPending}
          >
            Hủy
          </Button>
          <Button
            type="button"
            variant={action.destructive ? 'default' : 'yellow'}
            onClick={onConfirm}
            disabled={isPending}
          >
            {isPending ? 'Đang lưu...' : action.confirmLabel}
          </Button>
        </div>
      </section>
    </div>
  );
}
