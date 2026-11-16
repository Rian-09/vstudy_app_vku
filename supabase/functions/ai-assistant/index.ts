import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authorization } } },
  );
  const { data: { user }, error: userError } = await supabase.auth.getUser();
  if (userError || !user) return json({ error: 'Unauthorized' }, 401);

  const body = await request.json().catch(() => null) as { question?: unknown; context?: unknown } | null;
  const question = typeof body?.question === 'string' ? body.question.trim() : '';
  const context = typeof body?.context === 'string' ? body.context.trim() : '';
  if (!question || question.length > 4000) {
    return json({ error: 'Question must contain 1-4000 characters.' }, 400);
  }
  if (context.length > 8000) return json({ error: 'Context is too long.' }, 400);

  const apiKey = Deno.env.get('GEMINI_API_KEY');
  const model = Deno.env.get('GEMINI_MODEL') ?? 'gemini-3.8-flash';
  if (!apiKey) return json({ error: 'AI service is not configured.' }, 503);

  const prompt = [
    'Bạn là trợ lý học tập của V-STUDY cho sinh viên VKU. Trả lời bằng tiếng Việt, rõ ràng và trung thực.',
    context ? `Ngữ cảnh học tập:\n${context}` : '',
    `Câu hỏi của sinh viên:\n${question}`,
  ].filter(Boolean).join('\n\n');

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 30000);
  try {
    const result = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: [{ role: 'user', parts: [{ text: prompt }] }] }),
        signal: controller.signal,
      },
    );
    const payload = await result.json();
    if (!result.ok) return json({ error: `Gemini request failed (HTTP ${result.status}).` }, 502);
    const answer = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof answer !== 'string' || !answer.trim()) return json({ error: 'Gemini returned no answer.' }, 502);
    return json({ answer: answer.trim(), model });
  } catch {
    return json({ error: 'AI request timed out or failed.' }, 504);
  } finally {
    clearTimeout(timeout);
  }
});
