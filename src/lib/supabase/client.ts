import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase =
  supabaseUrl && supabaseAnonKey
    ? createClient(supabaseUrl, supabaseAnonKey)
    : null;

export function requireSupabase() {
  if (!supabase) {
    throw new Error(
      'Thiếu cấu hình Supabase. Hãy tạo file .env từ .env.example và điền VITE_SUPABASE_URL cùng VITE_SUPABASE_ANON_KEY.',
    );
  }
  return supabase;
}
