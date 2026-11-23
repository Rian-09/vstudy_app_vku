import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import type { Session } from '@supabase/supabase-js';
import { toast } from 'sonner';
import { requireSupabase, supabase } from '../../lib/supabase/client';

export interface AdminProfile {
  id: string;
  email: string;
  full_name: string;
  role: string;
}

type AuthStatus = 'loading' | 'signedOut' | 'authenticated' | 'denied' | 'error';

interface AuthState {
  status: AuthStatus;
  profile: AdminProfile | null;
  error: string | null;
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>(() => ({
    status: supabase ? 'loading' : 'signedOut',
    profile: null,
    error: null,
  }));
  const stateRef = useRef(state);
  const requestId = useRef(0);

  const updateState = useCallback((next: AuthState) => {
    stateRef.current = next;
    setState(next);
  }, []);

  const resolveSession = useCallback(
    async (session: Session | null) => {
      const currentRequest = ++requestId.current;
      if (!session) {
        if (stateRef.current.status !== 'denied') {
          updateState({ status: 'signedOut', profile: null, error: null });
        }
        return;
      }

      const currentState = stateRef.current;
      const isRefreshingCurrentUser =
        currentState.status === 'authenticated' &&
        currentState.profile?.id === session.user.id;
      if (!isRefreshingCurrentUser) {
        updateState({ status: 'loading', profile: null, error: null });
      }

      try {
        const client = requireSupabase();
        const { data, error } = await client
          .from('profiles')
          .select('id, email, full_name, role, is_locked')
          .eq('id', session.user.id)
          .maybeSingle();

        if (currentRequest !== requestId.current) return;
        if (error) throw error;

        const isAdmin = data?.role?.toUpperCase() === 'ADMIN';
        if (!data || !isAdmin || data.is_locked) {
          updateState({ status: 'denied', profile: null, error: null });
          await client.auth.signOut();
          return;
        }

        updateState({
          status: 'authenticated',
          profile: {
            id: data.id,
            email: data.email,
            full_name: data.full_name ?? '',
            role: data.role,
          },
          error: null,
        });
      } catch (error) {
        if (currentRequest === requestId.current) {
          if (isRefreshingCurrentUser) {
            toast.error(
              `Không thể xác minh lại quyền quản trị: ${
                error instanceof Error
                  ? error.message
                  : 'Vui lòng thử lại sau.'
              }`,
            );
            return;
          }
          updateState({
            status: 'error',
            profile: null,
            error:
              error instanceof Error
                ? error.message
                : 'Không thể xác minh quyền quản trị.',
          });
        }
      }
    },
    [updateState],
  );

  useEffect(() => {
    const client = supabase;
    if (!client) {
      updateState({ status: 'signedOut', profile: null, error: null });
      return;
    }
    const {
      data: { subscription },
    } = client.auth.onAuthStateChange((_event, session) => {
      void resolveSession(session);
    });

    void client.auth
      .getSession()
      .then(({ data, error }) => {
        if (error) throw error;
        return resolveSession(data.session);
      })
      .catch((error: unknown) => {
        updateState({
          status: 'error',
          profile: null,
          error:
            error instanceof Error
              ? error.message
              : 'Không thể kiểm tra phiên đăng nhập.',
        });
      });

    return () => {
      requestId.current += 1;
      subscription.unsubscribe();
    };
  }, [resolveSession, updateState]);

  const login = useCallback(
    async (email: string, password: string) => {
      const normalizedEmail = email.trim().toLowerCase();
      if (!normalizedEmail.endsWith('@vku.udn.vn')) {
        throw new Error('Chỉ được sử dụng email @vku.udn.vn.');
      }

      updateState({ status: 'loading', profile: null, error: null });
      const client = requireSupabase();
      const { data, error } = await client.auth.signInWithPassword({
        email: normalizedEmail,
        password,
      });
      if (error) {
        updateState({ status: 'signedOut', profile: null, error: null });
        throw error;
      }
      await resolveSession(data.session);
    },
    [resolveSession, updateState],
  );

  const logout = useCallback(async () => {
    updateState({ status: 'loading', profile: null, error: null });
    const { error } = await requireSupabase().auth.signOut();
    if (error) {
      updateState({
        status: 'error',
        profile: null,
        error: error.message,
      });
      throw error;
    }
    updateState({ status: 'signedOut', profile: null, error: null });
  }, [updateState]);

  return (
    <AuthContext.Provider value={{ ...state, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth phải được dùng trong AuthProvider.');
  return context;
}
