import { requireSupabase } from '../../lib/supabase/client';
import type {
  AccountActivitySummary,
  AccountPage,
  AccountRole,
  AdminAccount,
  AccountStatus,
} from './types';

const ACCOUNT_COLUMNS = 'id, email, full_name, role, is_locked, created_at';

interface AccountFilters {
  page: number;
  pageSize: number;
  search: string;
  role: AccountRole | 'all';
  status: AccountStatus | 'all';
}

export async function fetchAccounts({
  page,
  pageSize,
  search,
  role,
  status,
}: AccountFilters): Promise<AccountPage> {
  const client = requireSupabase();
  const from = page * pageSize;
  let query = client
    .from('profiles')
    .select(ACCOUNT_COLUMNS, { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, from + pageSize - 1);

  if (role !== 'all') query = query.eq('role', role);
  if (status === 'active') query = query.eq('is_locked', false);
  if (status === 'locked') query = query.eq('is_locked', true);

  const normalizedSearch = search.trim();
  if (normalizedSearch) {
    const escaped = normalizedSearch
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/[(),]/g, '\\$&');
    query = query.or(
      `full_name.ilike."%${escaped}%",email.ilike."%${escaped}%"`,
    );
  }

  const { data, error, count } = await query;
  if (error) throw error;

  return {
    accounts: (data ?? []) as AdminAccount[],
    total: count ?? 0,
  };
}

export async function updateAccountAccess(
  accountId: string,
  role: AccountRole,
  isLocked: boolean,
) {
  const { error } = await requireSupabase().rpc('admin_update_account', {
    p_target_user_id: accountId,
    p_role: role,
    p_is_locked: isLocked,
  });
  if (error) throw error;
}

export async function fetchAccountActivity(
  accountId: string,
): Promise<AccountActivitySummary> {
  const { data, error } = await requireSupabase()
    .rpc('admin_user_activity_summary', { p_user_id: accountId })
    .single();
  if (error) throw error;
  return data as AccountActivitySummary;
}
