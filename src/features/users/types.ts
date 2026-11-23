export type AccountRole = 'STUDENT' | 'ADMIN';
export type AccountStatus = 'active' | 'locked';

export interface AdminAccount {
  id: string;
  email: string;
  full_name: string;
  role: AccountRole;
  is_locked: boolean;
  created_at: string;
}

export interface AccountPage {
  accounts: AdminAccount[];
  total: number;
}

export interface AccountActivitySummary {
  quiz_attempt_count: number;
  recorded_study_minutes: number;
  last_recorded_activity: string | null;
}
