import { AlertTriangle } from 'lucide-react';
import { Button } from './button';

interface ConfirmDialogProps {
  title: string;
  description: string;
  confirmLabel: string;
  isDestructive?: boolean;
  isPending?: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}

export function ConfirmDialog({
  title,
  description,
  confirmLabel,
  isDestructive = false,
  isPending = false,
  onCancel,
  onConfirm,
}: ConfirmDialogProps) {
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
        aria-labelledby="confirm-dialog-title"
        className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
      >
        <div className="flex items-start gap-3">
          {isDestructive && (
            <span className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-red-50 text-brand-red">
              <AlertTriangle size={19} />
            </span>
          )}
          <div>
            <h2
              id="confirm-dialog-title"
              className="text-lg font-bold text-brand-ink"
            >
              {title}
            </h2>
            <p className="mt-2 text-sm leading-6 text-brand-muted">
              {description}
            </p>
          </div>
        </div>
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
            variant={isDestructive ? 'default' : 'yellow'}
            onClick={onConfirm}
            disabled={isPending}
          >
            {isPending ? 'Đang xử lý...' : confirmLabel}
          </Button>
        </div>
      </section>
    </div>
  );
}
