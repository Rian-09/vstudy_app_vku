import { zodResolver } from '@hookform/resolvers/zod';
import { LockKeyhole, ShieldCheck } from 'lucide-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { getErrorMessage } from '../../lib/errors';
import { supabase } from '../../lib/supabase/client';
import { useAuth } from './AuthProvider';

const loginSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email('Vui lòng nhập email hợp lệ.')
    .refine((value) => value.endsWith('@vku.udn.vn'), {
      message: 'Chỉ được sử dụng email @vku.udn.vn.',
    }),
  password: z.string().min(1, 'Vui lòng nhập mật khẩu.'),
});

type LoginValues = z.infer<typeof loginSchema>;

export function LoginPage() {
  const { login } = useAuth();
  const [submitError, setSubmitError] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginValues>({ resolver: zodResolver(loginSchema) });

  const onSubmit = handleSubmit(async (values) => {
    setSubmitError(null);
    try {
      await login(values.email, values.password);
    } catch (error) {
      setSubmitError(getErrorMessage(error));
    }
  });

  return (
    <main className="flex min-h-screen items-center justify-center bg-brand-surface px-4 py-10">
      <div className="grid w-full max-w-5xl overflow-hidden rounded-3xl bg-white shadow-panel md:grid-cols-[1.05fr_0.95fr]">
        <section className="relative hidden min-h-[600px] flex-col justify-between overflow-hidden bg-brand-blue p-12 text-white md:flex">
          <div className="absolute -right-20 -top-20 h-72 w-72 rounded-full bg-brand-yellow/20" />
          <div className="absolute -bottom-28 -left-20 h-80 w-80 rounded-full border-[36px] border-white/10" />
          <div className="relative flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-2xl bg-brand-yellow text-brand-ink">
              <ShieldCheck size={24} />
            </div>
            <div>
              <p className="text-lg font-extrabold tracking-wide">V-STUDY</p>
              <p className="text-xs text-white/65">VKU learning platform</p>
            </div>
          </div>
          <div className="relative max-w-md">
            <p className="mb-4 text-sm font-semibold uppercase tracking-[0.2em] text-brand-yellow">
              Admin workspace
            </p>
            <h1 className="text-4xl font-bold leading-tight">
              Quản trị nội dung học tập, đơn giản và tập trung.
            </h1>
            <p className="mt-5 leading-7 text-white/75">
              Không gian dành riêng cho quản trị viên V-STUDY tại Đại học
              CNTT và Truyền thông Việt - Hàn.
            </p>
          </div>
          <p className="relative text-xs text-white/50">
            Chỉ tài khoản quản trị VKU được cấp quyền mới có thể truy cập.
          </p>
        </section>

        <section className="flex min-h-[600px] flex-col justify-center px-6 py-12 sm:px-12">
          <div className="mb-8 md:hidden">
            <p className="text-xl font-extrabold text-brand-blue">V-STUDY</p>
            <p className="text-sm text-brand-muted">Admin workspace</p>
          </div>
          <div className="mb-8">
            <div className="mb-5 grid h-12 w-12 place-items-center rounded-2xl bg-brand-yellow/25 text-brand-blue">
              <LockKeyhole size={23} />
            </div>
            <h2 className="text-2xl font-bold text-brand-ink">Đăng nhập quản trị</h2>
            <p className="mt-2 text-sm leading-6 text-brand-muted">
              Sử dụng tài khoản VKU đã được cấp role ADMIN trong Supabase.
            </p>
          </div>

          {!supabase && (
            <div className="mb-5 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
              Chưa cấu hình Supabase. Tạo file <code>.env</code> từ{' '}
              <code>.env.example</code>, sau đó điền URL và anon key.
            </div>
          )}

          <form className="space-y-5" onSubmit={onSubmit} noValidate>
            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Email VKU
              <Input
                type="email"
                autoComplete="username"
                placeholder="ten@vku.udn.vn"
                aria-invalid={Boolean(errors.email)}
                {...register('email')}
              />
              {errors.email && (
                <span className="block text-xs font-medium text-brand-red">
                  {errors.email.message}
                </span>
              )}
            </label>

            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Mật khẩu
              <Input
                type="password"
                autoComplete="current-password"
                placeholder="Nhập mật khẩu"
                aria-invalid={Boolean(errors.password)}
                {...register('password')}
              />
              {errors.password && (
                <span className="block text-xs font-medium text-brand-red">
                  {errors.password.message}
                </span>
              )}
            </label>

            {submitError && (
              <div
                role="alert"
                className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800"
              >
                {submitError}
              </div>
            )}

            <Button
              type="submit"
              className="w-full"
              disabled={isSubmitting || !supabase}
            >
              {isSubmitting ? 'Đang xác thực...' : 'Đăng nhập'}
            </Button>
          </form>

          <p className="mt-6 text-center text-xs leading-5 text-brand-muted">
            Đăng nhập được xác thực qua Supabase Auth và role trong bảng
            profiles.
          </p>
        </section>
      </div>
    </main>
  );
}
