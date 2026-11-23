import { useQuery } from '@tanstack/react-query';
import { unzipSync, strFromU8 } from 'fflate';
import { X } from 'lucide-react';
import { renderAsync } from 'docx-preview';
import { useEffect, useRef, useState } from 'react';
import { Button } from '../../components/ui/button';
import {
  createSignedDocumentUrl,
  getDocumentExtension,
  getDocumentFileName,
} from './documentService';
import type { StudyDocument } from './types';

interface DocumentPreviewDialogProps {
  document: StudyDocument;
  onClose: () => void;
  onDownload: (document: StudyDocument) => void;
}

export function DocumentPreviewDialog({
  document,
  onClose,
  onDownload,
}: DocumentPreviewDialogProps) {
  const extension = getDocumentExtension(document);
  const previewQuery = useQuery({
    queryKey: ['document-preview-url', document.id],
    queryFn: async () => {
      const url = await createSignedDocumentUrl(document.file_path);
      if (extension === 'pdf') return { kind: 'pdf' as const, url };
      if (extension === 'docx') return { kind: 'docx' as const, url };

      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`Tải tài liệu xem trước thất bại (${response.status}).`);
      }
      if (extension === 'txt') {
        return { kind: 'text' as const, text: await response.text() };
      }
      const bytes = new Uint8Array(await response.arrayBuffer());
      if (extension === 'pptx') {
        const archive = unzipSync(bytes);
        const slideFiles = Object.keys(archive)
          .filter((path) => /^ppt\/slides\/slide\d+\.xml$/.test(path))
          .sort((left, right) =>
            left.localeCompare(right, undefined, { numeric: true }),
          );
        const slides = slideFiles.map((path, index) => {
          const xml = strFromU8(archive[path]);
          const text = [...xml.matchAll(/<a:t\b[^>]*>([\s\S]*?)<\/a:t>/g)]
            .map((match) => decodeXml(match[1]))
            .filter(Boolean)
            .join(' ');
          return { number: index + 1, text };
        });
        if (slides.length === 0) {
          throw new Error('Không tìm thấy nội dung slide trong tệp PPTX.');
        }
        return { kind: 'slides' as const, slides };
      }
      throw new Error('Định dạng này chưa hỗ trợ xem trước.');
    },
  });

  return (
    <div
      className="fixed inset-0 z-30 flex flex-col bg-slate-950/70 p-3 sm:p-6"
      role="dialog"
      aria-modal="true"
      aria-labelledby="document-preview-title"
    >
      <header className="flex items-center justify-between rounded-t-2xl bg-white px-4 py-3">
        <div className="min-w-0">
          <h2
            id="document-preview-title"
            className="truncate text-sm font-bold text-brand-ink"
          >
            {document.title}
          </h2>
          <p className="text-xs uppercase text-brand-muted">
            {getDocumentFileName(document)} · {extension}
          </p>
          {extension !== 'pdf' && extension !== 'docx' && (
            <p className="text-[11px] text-brand-muted">
              Bản xem trước trích xuất nội dung văn bản; hình ảnh và biểu đồ
              có thể không được hiển thị.
            </p>
          )}
        </div>
        <div className="ml-3 flex shrink-0 gap-1">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onDownload(document)}
          >
            Tải xuống
          </Button>
          <Button
            variant="ghost"
            size="icon"
            aria-label="Đóng bản xem trước"
            onClick={onClose}
          >
            <X size={19} />
          </Button>
        </div>
      </header>
      <div className="flex-1 overflow-hidden rounded-b-2xl bg-slate-100">
        {previewQuery.isPending && (
          <p className="p-6 text-sm text-brand-muted">Đang tạo liên kết xem...</p>
        )}
        {previewQuery.isError && (
          <p role="alert" className="p-6 text-sm text-brand-red">
            Không thể tải bản xem trước.{' '}
            {previewQuery.error instanceof Error
              ? previewQuery.error.message
              : 'Vui lòng thử tải xuống.'}
          </p>
        )}
        {previewQuery.data?.kind === 'pdf' && (
          <iframe
            title={`Bản xem trước ${document.title}`}
            src={previewQuery.data.url}
            className="h-full min-h-[65vh] w-full border-0"
          />
        )}
        {previewQuery.data?.kind === 'docx' && (
          <DocxDocumentPreview url={previewQuery.data.url} />
        )}
        {previewQuery.data?.kind === 'text' && (
          <pre className="h-full min-h-[65vh] overflow-auto whitespace-pre-wrap break-words p-5 text-sm leading-7 text-slate-800">
            {previewQuery.data.text || 'Tài liệu không có nội dung văn bản.'}
          </pre>
        )}
        {previewQuery.data?.kind === 'slides' && (
          <div className="h-full min-h-[65vh] space-y-4 overflow-auto p-5">
            {previewQuery.data.slides.map((slide) => (
              <article
                key={slide.number}
                className="mx-auto max-w-4xl rounded-xl border border-slate-200 bg-white p-5 shadow-sm"
              >
                <h3 className="text-xs font-bold uppercase tracking-wide text-brand-blue">
                  Slide {slide.number}
                </h3>
                <p className="mt-3 whitespace-pre-wrap text-sm leading-7 text-brand-ink">
                  {slide.text || 'Slide không có nội dung văn bản.'}
                </p>
              </article>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function DocxDocumentPreview({ url }: { url: string }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;
    let isCurrent = true;
    container.replaceChildren();
    setIsLoading(true);
    setError(null);

    void fetch(url)
      .then(async (response) => {
        if (!response.ok) {
          throw new Error(`Tải DOCX thất bại (${response.status}).`);
        }
        return response.arrayBuffer();
      })
      .then((data) =>
        renderAsync(data, container, container, {
          breakPages: true,
          ignoreWidth: false,
          ignoreHeight: false,
          renderHeaders: true,
          renderFooters: true,
          renderAltChunks: false,
        }),
      )
      .then(() => {
        if (isCurrent) setIsLoading(false);
      })
      .catch((cause: unknown) => {
        if (!isCurrent) return;
        setError(
          cause instanceof Error
            ? cause.message
            : 'Không thể dựng bản xem trước DOCX.',
        );
        setIsLoading(false);
      });

    return () => {
      isCurrent = false;
      container.replaceChildren();
    };
  }, [url]);

  return (
    <div
      className="relative h-full min-h-[65vh] overflow-auto bg-slate-200 p-4"
      onClickCapture={(event) => {
        if (event.target instanceof Element && event.target.closest('a')) {
          event.preventDefault();
        }
      }}
    >
      {isLoading && (
        <p className="sticky top-0 z-10 rounded-lg bg-white/90 p-3 text-sm text-brand-muted">
          Đang dựng các trang DOCX...
        </p>
      )}
      {error && (
        <p role="alert" className="rounded-lg bg-red-50 p-4 text-sm text-brand-red">
          Không thể dựng bản xem trước DOCX. {error}
        </p>
      )}
      <div ref={containerRef} />
    </div>
  );
}

function decodeXml(value: string) {
  return value.replace(
    /&(#x[0-9a-f]+|#\d+|amp|lt|gt|quot|apos);/gi,
    (entity, value: string) => {
      if (value[0] === '#') {
        const code = value[1]?.toLowerCase() === 'x'
          ? Number.parseInt(value.slice(2), 16)
          : Number.parseInt(value.slice(1), 10);
        return Number.isFinite(code) && code <= 0x10ffff
          ? String.fromCodePoint(code)
          : entity;
      }
      const entities: Record<string, string> = {
        amp: '&',
        lt: '<',
        gt: '>',
        quot: '"',
        apos: "'",
      };
      return entities[value.toLowerCase()] ?? entity;
    },
  );
}
