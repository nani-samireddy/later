import { GoogleGenAI } from '@google/genai';

const model = 'gemini-3.5-transcribe-live';
const reply = (body, status = 200) => Response.json(body, {
  status, headers: {'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff'},
});
export function createWorker(mint = async (env, config) => {
  const ai = new GoogleGenAI({apiKey: env.GEMINI_API_KEY, httpOptions: {apiVersion: 'v1beta', timeout: 15000}});
  return ai.authTokens.create({config});
}) {
  return {
    async fetch(request, env) {
      const path = new URL(request.url).pathname;
      if (path === '/health' && request.method === 'GET') return reply({service: 'later-voice-token'});
      if (path !== '/token') return reply({error: 'Not found'}, 404);
      if (request.method !== 'POST') return reply({error: 'Method not allowed'}, 405);
      if (!env.GEMINI_API_KEY || !env.REQUEST_LIMIT || !env.TOKEN_LIMIT) {
        return reply({error: 'Voice service is not configured'}, 503);
      }
      // Limit public token requests before provisioning.
      const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
      if (!(await env.REQUEST_LIMIT.limit({key: ip})).success) return reply({error: 'Too many requests'}, 429);
      if (!(await env.TOKEN_LIMIT.limit({key: 'closed-testing'})).success) return reply({error: 'Too many voice sessions'}, 429);
      try {
        const now = Date.now();
        const token = await mint(env, {
          uses: 1,
          expireTime: new Date(now + 6 * 60 * 1000).toISOString(),
          newSessionExpireTime: new Date(now + 60 * 1000).toISOString(),
          liveConnectConstraints: {
            model,
            config: {responseModalities: ['TEXT'], inputAudioTranscription: {languageCodes: []}},
          },
        });
        if (!token.name) return reply({error: 'Voice service unavailable'}, 502);
        return reply({token: token.name, model, sessionSeconds: 300});
      } catch {
        // Do not relay provider errors, secrets or tokens.
        return reply({error: 'Voice service unavailable'}, 502);
      }
    },
  };
}
export default createWorker();
