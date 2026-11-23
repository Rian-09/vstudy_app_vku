import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from './AuthProvider';
import { LoadingScreen } from '../../components/LoadingScreen';

export function ProtectedRoute() {
  const { status } = useAuth();

  if (status === 'loading') return <LoadingScreen />;
  if (status === 'denied') return <Navigate to="/access-denied" replace />;
  if (status !== 'authenticated') return <Navigate to="/login" replace />;
  return <Outlet />;
}

export function PublicOnlyRoute() {
  const { status } = useAuth();

  if (status === 'loading') return <LoadingScreen />;
  if (status === 'authenticated') return <Navigate to="/" replace />;
  if (status === 'denied') return <Navigate to="/access-denied" replace />;
  return <Outlet />;
}
