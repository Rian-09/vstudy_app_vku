import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});

const MAX_UPLOAD_BYTES = 15 * 1024 * 1024;
const MAX_TEXT_CHARS = 100_000;
const MODEL_FALLBACK = 'gemini-3.8-flash';

type UploadedFile = { name?: unknown; content_type?: unknown; base64?: unknown; extracted_text?: unknown };
type GatewayBody = {
  action?: unknown;
  document_id?: unknown;
  uploaded_file?: UploadedFile;
  chat_id?: unknown;
  question?: unknown;
  goal?: unknown;
  duration_minutes?: unknown;
};

function decodeBase64(value: string): Uint8Array | null {
  try {
    const binary = atob(value.replace(/^data:[^,]+,/, ''));
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes;
  } catch {
    return null;
  }
}

function errorMessage(value: unknown): string {
  if (value && typeof value === 'object' && 'message' in value) {
    return String((value as { message: unknown }).message);
  }
  return String(value ?? 'Unknown error');
}

function safeJson(text: string): unknown | null {
  const cleaned = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  try { return JSON.parse(cleaned); } catch { return null; }
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ code: 'method_not_allowed', error: 'Chỉ hỗ trợ POST.' }, 405);

  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) {
    return json({ code: 'unauthorized', error: 'Vui lòng đăng nhập để sử dụng AI.' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  if (!supabaseUrl || !anonKey) {
    return json({ code: 'server_not_configured', error: 'Dịch vụ chưa được cấu hình.' }, 503);
  }

  // Mọi truy vấn dùng JWT người dùng để RLS giới hạn dữ liệu.
  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return json({ code: 'unauthorized', error: 'Phiên đăng nhập không hợp lệ.' }, 401);

  const body = await request.json().catch(() => null) as GatewayBody | null;
  if (!body || typeof body !== 'object') {
    return json({ code: 'invalid_request', error: 'Dữ liệu gửi lên không hợp lệ.' }, 400);
  }

  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) return json({ code: 'ai_not_configured', error: 'Dịch vụ AI chưa được cấu hình.' }, 503);
  const model = Deno.env.get('GEMINI_MODEL') ?? MODEL_FALLBACK;
  const action = typeof body.action === 'string' ? body.action : '';
  const startedAt = new Date();

  const recordSession = async (activityType: 'summary' | 'qa', documentId: string | null, subject: string | null) => {
    const endedAt = new Date();
    const rawDuration = Number(body.duration_minutes);
    const duration = Number.isFinite(rawDuration) ? Math.min(1440, Math.max(0, Math.floor(rawDuration))) : 1;
    const { error } = await supabase.from('study_sessions').insert({
      user_id: user.id,
      document_id: documentId,
      subject,
      started_at: startedAt.toISOString(),
      ended_at: endedAt.toISOString(),
      duration_minutes: duration,
      activity_type: activityType,
    });
    if (error) console.error('study session insert failed:', error.message);
  };

  const generate = async (prompt: string, inlineData?: { mimeType: string; data: string }) => {
    const parts: Array<Record<string, unknown>> = [{ text: prompt }];
    if (inlineData) parts.push({ inline_data: { mime_type: inlineData.mimeType, data: inlineData.data } });
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 55_000);
    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${apiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents: [{ role: 'user', parts }] }),
          signal: controller.signal,
        },
      );
      const payload = await response.json().catch(() => ({}));
      if (!response.ok) {
        const message = errorMessage(payload?.error);
        if (response.status === 429 || /quota|rate.?limit/i.test(message)) {
          throw Object.assign(new Error('AI đang quá tải hoặc đã hết quota. Vui lòng thử lại sau.'), { code: 'quota_exceeded', status: 429 });
        }
        console.error('Gemini request failed:', response.status, message);
        throw Object.assign(new Error('AI chưa thể xử lý yêu cầu. Vui lòng thử lại sau.'), { code: 'gemini_error', status: 502 });
      }
      const answer = payload?.candidates?.[0]?.content?.parts
        ?.map((part: { text?: unknown }) => typeof part.text === 'string' ? part.text : '')
        .join('').trim();
      if (!answer) throw Object.assign(new Error('AI không trả về nội dung.'), { code: 'empty_ai_response', status: 502 });
      return answer as string;
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') {
        throw Object.assign(new Error('AI phản hồi quá thời gian. Vui lòng thử lại.'), { code: 'ai_timeout', status: 504 });
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  };

  const loadDocument = async (documentId: string) => {
    const { data, error } = await supabase.from('documents')
      .select('id,user_id,title,subject,file_path,file_type,file_size,extracted_text,is_published')
      .eq('id', documentId).maybeSingle();
    if (error || !data || (data.user_id !== user.id && data.is_published !== true)) {
      throw Object.assign(new Error('Không tìm thấy tài liệu hoặc bạn không có quyền truy cập.'), { code: 'document_not_found', status: 404 });
    }
    return data;
  };

  const documentContent = async (document: Record<string, unknown>) => {
    const extracted = typeof document.extracted_text === 'string' ? document.extracted_text.trim() : '';
    if (extracted) return { text: extracted.slice(0, MAX_TEXT_CHARS), inlineData: undefined as { mimeType: string; data: string } | undefined };
    const filePath = typeof document.file_path === 'string' ? document.file_path : '';
    if (!filePath) throw Object.assign(new Error('Tài liệu chưa có nội dung để AI đọc.'), { code: 'file_not_readable', status: 422 });
    const { data: file, error } = await supabase.storage.from('documents').download(filePath);
    if (error || !file) throw Object.assign(new Error('Không tải được tệp tài liệu.'), { code: 'file_not_readable', status: 422 });
    if (file.size > MAX_UPLOAD_BYTES) throw Object.assign(new Error('Tệp vượt quá giới hạn 15 MB.'), { code: 'file_too_large', status: 413 });
    const mimeType = typeof document.file_type === 'string' && document.file_type.toLowerCase().includes('pdf')
      ? 'application/pdf'
      : file.type || 'application/octet-stream';
    if (mimeType !== 'application/pdf') {
      throw Object.assign(new Error('Không đọc được định dạng này. Hãy bổ sung phần trích xuất văn bản hoặc dùng PDF.'), { code: 'file_not_readable', status: 422 });
    }
    const bytes = new Uint8Array(await file.arrayBuffer());
    let binary = '';
    for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
    return { text: '', inlineData: { mimeType, data: btoa(binary) } };
  };

  try {
    if (action === 'summarize') {
      const documentId = typeof body.document_id === 'string' ? body.document_id : null;
      let sourceName = '';
      let document: Record<string, unknown> | null = null;
      let text = '';
      let inlineData: { mimeType: string; data: string } | undefined;
      let sourceType: 'saved' | 'uploaded' = 'uploaded';
      if (documentId) {
        document = await loadDocument(documentId) as unknown as Record<string, unknown>;
        sourceName = String(document.title ?? 'Tài liệu');
        sourceType = 'saved';
        ({ text, inlineData } = await documentContent(document));
      } else {
        const uploaded = body.uploaded_file;
        const name = typeof uploaded?.name === 'string' ? uploaded.name.slice(0, 255) : '';
        const mimeType = typeof uploaded?.content_type === 'string' ? uploaded.content_type : '';
        const encoded = typeof uploaded?.base64 === 'string' ? uploaded.base64 : '';
        const extractedText = typeof uploaded?.extracted_text === 'string' ? uploaded.extracted_text.trim() : '';
        if (!name || (!encoded && !extractedText)) return json({ code: 'invalid_upload', error: 'Thiếu tệp hoặc nội dung tệp cần tóm tắt.' }, 400);
        sourceName = name;
        if (extractedText) {
          text = extractedText.slice(0, MAX_TEXT_CHARS);
        } else {
          const bytes = decodeBase64(encoded);
          if (!bytes) return json({ code: 'file_not_readable', error: 'Dữ liệu tệp không hợp lệ.' }, 422);
          if (bytes.byteLength > MAX_UPLOAD_BYTES) return json({ code: 'file_too_large', error: 'Tệp vượt quá giới hạn 15 MB.' }, 413);
          if (mimeType !== 'application/pdf') return json({ code: 'file_not_readable', error: 'Định dạng này cần gửi kèm extracted_text hoặc chuyển sang PDF.' }, 422);
          let binary = '';
          for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
          inlineData = { mimeType, data: btoa(binary) };
        }
      }
      const prompt = `Bạn là trợ lý học tập V-Study. Hãy tóm tắt tài liệu bằng tiếng Việt, chia thành các ý chính, khái niệm/công thức quan trọng và phần cần ghi nhớ. Không tự bịa nội dung.\n\n${text ? `Nội dung tài liệu:\n${text}` : `Hãy đọc tệp PDF đính kèm có tên ${sourceName}.`}`;
      const content = await generate(prompt, inlineData);
      const { data: summary, error } = await supabase.from('ai_summaries').insert({
        user_id: user.id,
        document_id: documentId,
        source_type: sourceType,
        source_name: sourceName,
        content,
      }).select('id,document_id,source_type,source_name,content,created_at').single();
      if (error) throw Object.assign(new Error('Không lưu được lịch sử tóm tắt.'), { code: 'summary_save_failed', status: 500 });
      await recordSession('summary', documentId, document ? String(document.subject ?? '') || null : null);
      return json({ summary, content, model });
    }

    if (action === 'ask') {
      const question = typeof body.question === 'string' ? body.question.trim() : '';
      const chatId = typeof body.chat_id === 'string' ? body.chat_id : '';
      const documentId = typeof body.document_id === 'string' ? body.document_id : null;
      if (!question || question.length > 4000) return json({ code: 'invalid_question', error: 'Câu hỏi cần có từ 1 đến 4000 ký tự.' }, 400);
      if (!chatId) return json({ code: 'invalid_chat', error: 'Thiếu cuộc trò chuyện.' }, 400);
      const { data: chat, error: chatError } = await supabase.from('ai_chats')
        .select('id,document_id').eq('id', chatId).eq('user_id', user.id).maybeSingle();
      if (chatError || !chat) return json({ code: 'chat_not_found', error: 'Không tìm thấy cuộc trò chuyện.' }, 404);
      const effectiveDocumentId = documentId ?? chat.document_id as string | null;
      let context = '';
      let subject: string | null = null;
      let inlineData: { mimeType: string; data: string } | undefined;
      if (effectiveDocumentId) {
        const document = await loadDocument(effectiveDocumentId);
        subject = typeof document.subject === 'string' ? document.subject : null;
        const content = await documentContent(document);
        inlineData = content.inlineData;
        context = content.text || 'Tệp PDF được đính kèm ở lượt hỏi đầu.';
      }
      const { data: history } = await supabase.from('ai_messages').select('role,content')
        .eq('chat_id', chatId).eq('user_id', user.id).order('created_at', { ascending: false }).limit(12);
      const orderedHistory = (history ?? []).reverse();
      const { error: userMessageError } = await supabase.from('ai_messages').insert({
        user_id: user.id, chat_id: chatId, role: 'user', content: question,
      });
      if (userMessageError) throw Object.assign(new Error('Không lưu được câu hỏi.'), { code: 'message_save_failed', status: 500 });
      const prompt = [
        'Bạn là trợ lý học tập V-Study. Trả lời bằng tiếng Việt, rõ ràng, đúng trọng tâm; nếu không chắc thì nói rõ.',
        context ? `Theo tài liệu${subject ? ` môn ${subject}` : ''} dưới đây, hãy ưu tiên căn cứ nội dung này và nêu rõ khi trả lời theo tài liệu:\n${context.slice(0, MAX_TEXT_CHARS)}` : 'Đây là câu hỏi chung, không có tài liệu đính kèm.',
        orderedHistory.map((message) => `${message.role === 'assistant' ? 'Trợ lý' : 'Sinh viên'}: ${message.content}`).join('\n'),
        `Sinh viên: ${question}`,
      ].filter(Boolean).join('\n\n');
      const answer = await generate(prompt, inlineData);
      const { data: assistantMessage, error: answerError } = await supabase.from('ai_messages').insert({
        user_id: user.id, chat_id: chatId, role: 'assistant', content: answer,
      }).select('id,chat_id,role,content,created_at').single();
      if (answerError) throw Object.assign(new Error('Không lưu được câu trả lời.'), { code: 'message_save_failed', status: 500 });
      await recordSession('qa', effectiveDocumentId, subject);
      return json({ answer, message: assistantMessage, chat_id: chatId, model });
    }

    if (action === 'roadmap') {
      const goal = typeof body.goal === 'string' ? body.goal.trim() : '';
      if (!goal || goal.length > 1000) return json({ code: 'invalid_goal', error: 'Mục tiêu cần có từ 1 đến 1000 ký tự.' }, 400);
      const since = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString();
      const [sessionsResult, progressResult] = await Promise.all([
        supabase.from('study_sessions').select('subject,started_at,duration_minutes,activity_type').eq('user_id', user.id).gte('started_at', since).order('started_at', { ascending: false }).limit(500),
        supabase.from('reading_progress').select('document_id,current_page,total_pages,percent,last_opened_at,is_finished,documents(title,subject)').eq('user_id', user.id).eq('is_finished', false).order('last_opened_at', { ascending: false }).limit(100),
      ]);
      if (sessionsResult.error || progressResult.error) throw Object.assign(new Error('Không tải được thống kê học tập.'), { code: 'stats_load_failed', status: 500 });
      const sessions = sessionsResult.data ?? [];
      const minutesBySubject: Record<string, number> = {};
      const days = new Set<string>();
      for (const session of sessions) {
        const name = session.subject?.trim() || 'Chưa phân loại';
        minutesBySubject[name] = (minutesBySubject[name] ?? 0) + (Number(session.duration_minutes) || 0);
        days.add(String(session.started_at).slice(0, 10));
      }
      const basedOnStats = {
        period_days: 60,
        session_count: sessions.length,
        insufficient_data: sessions.length < 3,
        total_minutes: sessions.reduce((sum, item) => sum + (Number(item.duration_minutes) || 0), 0),
        study_days: days.size,
        minutes_by_subject: minutesBySubject,
        recent_sessions: sessions.slice(0, 100),
        unfinished_reading: (progressResult.data ?? []).map((item) => ({
          title: (item.documents as { title?: string } | null)?.title ?? 'Tài liệu',
          subject: (item.documents as { subject?: string } | null)?.subject ?? null,
          current_page: item.current_page,
          total_pages: item.total_pages,
          percent: item.percent,
          last_opened_at: item.last_opened_at,
        })),
      };
      const answer = await generate([
        'Tạo lộ trình học cá nhân hóa bằng tiếng Việt. Dữ liệu người học là dữ liệu thật bên dưới; không được bịa lịch sử.',
        'Chỉ trả về JSON hợp lệ, không markdown, theo cấu trúc: {"title":string,"overview":string,"weeks":[{"week":number,"focus":string,"days":[{"day":string,"tasks":[string],"minutes":number}]}]}.',
        basedOnStats.insufficient_data ? 'Người dùng có dưới 3 buổi học: hãy tạo lộ trình cơ bản dựa trên mục tiêu, đồng thời thận trọng vì dữ liệu còn ít.' : 'Cá nhân hóa khối lượng theo môn học và tài liệu còn đọc dở.',
        `Mục tiêu: ${goal}`,
        `Thống kê thật (60 ngày): ${JSON.stringify(basedOnStats)}`,
      ].join('\n\n'));
      const content = safeJson(answer);
      if (!content || typeof content !== 'object' || !Array.isArray((content as { weeks?: unknown }).weeks)) {
        throw Object.assign(new Error('AI trả về lộ trình không đúng định dạng. Vui lòng thử lại.'), { code: 'invalid_roadmap_response', status: 502 });
      }
      const { data: roadmap, error } = await supabase.from('study_roadmaps').insert({
        user_id: user.id, goal, content, based_on_stats: basedOnStats,
      }).select('id,goal,content,based_on_stats,created_at').single();
      if (error) throw Object.assign(new Error('Không lưu được lộ trình.'), { code: 'roadmap_save_failed', status: 500 });
      return json({ roadmap, based_on_stats: basedOnStats, insufficient_data: basedOnStats.insufficient_data, model });
    }

    return json({ code: 'invalid_action', error: 'Action không được hỗ trợ.' }, 400);
  } catch (error) {
    const status = typeof error === 'object' && error !== null && 'status' in error
      ? Number((error as { status: unknown }).status) : 500;
    const code = typeof error === 'object' && error !== null && 'code' in error
      ? String((error as { code: unknown }).code) : 'gateway_error';
    const message = errorMessage(error);
    if (status >= 500) console.error('ai-gateway error:', code, message);
    return json({ code, error: status >= 500 && code === 'gateway_error' ? 'Đã xảy ra lỗi khi xử lý yêu cầu AI.' : message }, status >= 400 && status <= 599 ? status : 500);
  }
});
