# QhySync AI Studio OS — Unified Cloudflare REST Backend Specification

## Document purpose
This document merges:
1) your full QhySync AI Studio OS vision (chat + models + training + voice/avatar + agents + governance), and
2) a **real, implementation-ready Cloudflare Workers REST backend router architecture** grounded in current Cloudflare API and platform docs.

It is written as a single source-of-truth spec you can hand to engineering for staged delivery.

---

## 1) Reality checks and non-negotiables

- **Installable PWA requires secure origin (`https://` or `localhost`)**. Do not target `file://` for installability/service-worker behavior.
- **Local-first remains mandatory**: browser storage for offline-first UX (IndexedDB/OPFS/local cache), with Cloudflare sync and replay.
- **Workers + D1 are the control plane and data plane backbone** for your edge backend.
- **Constitutional governance layer** (review, veto/escalation, emergency halt) is mandatory for high-impact actions.

---

## 2) Platform definition: QhySync AI Studio OS

### Core capability matrix
- QhySync Chat cockpit
- Local model host (no external API key dependency for core inference)
- Training lab (RAG ingestion + fine-tuning/evals)
- Voice lab (STT/TTS/STS + keyword engine)
- Avatar engine (lip sync + gestures + emotional states)
- Tool/MCP-style registry and execution bus
- Agent workforce orchestration + ledgered internal payouts
- Cloudflare worker fleet with route/event contracts
- Dual environment governance (staging + production)
- Obsidian bridge
- Offline queue + sync replay

### Logical architecture layers
1. **Experience layer**: PWA shell, chat UI, avatar/voice controls, project workspace.
2. **Application layer**: chat orchestration, tool runtime, workforce manager, training manager.
3. **Policy layer**: constitutional guardrails, approval gates, risk scoring.
4. **Data layer**: D1 relational stores + object/blob stores + local cache.
5. **Infrastructure layer**: Workers, Queues, KV, R2, bindings, observability.

---

## 3) Cloudflare target topology (implementation-grade)

```text
Internet
  -> api.<domain>      -> gateway-worker (HTTP router, authz, scopes)
  -> app.<domain>      -> app-worker (PWA + API pass-through where required)

gateway-worker
  -> service bindings -> chat-worker / training-worker / agent-manager-worker / voice-worker / docs-worker / deploy-worker
  -> D1 bindings      -> core/chat/training/agents/audit dbs
  -> Queues           -> async jobs, retries, replay, dead-letter
  -> KV               -> cache, idempotency keys, rate tokens
  -> R2               -> large artifacts (datasets, media, exports)
```

### Why this split
- Keeps API governance centralized at gateway.
- Allows independent deployment/versioning per domain capability.
- Reduces blast radius and enables fine-grained scaling/observability.

---

## 4) Worker fleet (phase-ordered)

### Phase 1 (must-have)
1. gateway-worker
2. auth-worker (or auth module in gateway)
3. chat-worker
4. tools-worker
5. agent-manager-worker
6. sync-worker
7. audit-worker

### Phase 2
8. model-control-worker
9. training-worker
10. embeddings-worker
11. docs-worker
12. keyword-worker
13. obsidian-worker

### Phase 3
14. voice-stt-worker
15. voice-tts-worker
16. voice-sts-worker
17. avatar-worker
18. eval-worker
19. deploy-worker
20. telemetry-worker

### Worker contract schema (required)
Every worker MUST ship:
- `routes[]`
- `events_in[]`
- `events_out[]`
- `dbs[]`
- `queues[]`
- `scopes[]`
- `risk_class`
- `approvals_required`

---

## 5) Unified REST route catalog (v1)

## 5.1 System / health / governance
- `GET /api/v1/health`
- `GET /api/v1/ready`
- `GET /api/v1/version`
- `POST /api/v1/governance/review`
- `POST /api/v1/governance/approve`
- `POST /api/v1/governance/reject`
- `POST /api/v1/governance/emergency-halt`

## 5.2 Chat
- `POST /api/v1/chat/send`
- `POST /api/v1/chat/stream`
- `POST /api/v1/chat/summarize`
- `POST /api/v1/chat/rewrite`
- `POST /api/v1/chat/branch`
- `POST /api/v1/chat/attach`
- `GET /api/v1/chat/history`
- `GET /api/v1/chat/sessions/:sessionId`
- `PATCH /api/v1/chat/sessions/:sessionId/title`
- `DELETE /api/v1/chat/sessions/:sessionId`

## 5.3 Models
- `GET /api/v1/models`
- `POST /api/v1/models/import`
- `POST /api/v1/models/load`
- `POST /api/v1/models/unload`
- `POST /api/v1/models/warm`
- `GET /api/v1/models/:modelId/status`
- `GET /api/v1/models/:modelId/capabilities`
- `POST /api/v1/models/:modelId/benchmark`

## 5.4 Training
- `POST /api/v1/training/datasets/create`
- `POST /api/v1/training/datasets/import`
- `POST /api/v1/training/datasets/:id/process`
- `POST /api/v1/training/jobs/create`
- `POST /api/v1/training/jobs/:id/start`
- `POST /api/v1/training/jobs/:id/pause`
- `POST /api/v1/training/jobs/:id/resume`
- `POST /api/v1/training/jobs/:id/cancel`
- `GET /api/v1/training/jobs`
- `GET /api/v1/training/jobs/:id`
- `GET /api/v1/training/metrics/:jobId`
- `POST /api/v1/training/evals/run`

## 5.5 Voice + avatar
- `POST /api/v1/voice/stt`
- `POST /api/v1/voice/tts`
- `POST /api/v1/voice/sts`
- `POST /api/v1/voice/clone/train`
- `POST /api/v1/voice/clone/validate`
- `GET /api/v1/voice/profiles`
- `PATCH /api/v1/voice/profiles/:voiceId`
- `POST /api/v1/avatar/lipsync`
- `POST /api/v1/avatar/gesture`
- `POST /api/v1/avatar/state`
- `GET /api/v1/avatar/config`

## 5.6 Commands and tools
- `POST /api/v1/commands/parse`
- `POST /api/v1/commands/execute`
- `POST /api/v1/commands/register`
- `GET /api/v1/commands/catalog`
- `GET /api/v1/commands/history`
- `GET /api/v1/tools`
- `POST /api/v1/tools/register`
- `GET /api/v1/tools/:toolId`
- `POST /api/v1/tools/:toolId/run`
- `PATCH /api/v1/tools/:toolId/scopes`
- `GET /api/v1/tools/:toolId/logs`

## 5.7 Agents
- `POST /api/v1/agents/register`
- `POST /api/v1/agents/create-template`
- `POST /api/v1/agents/:id/assign`
- `POST /api/v1/agents/:id/approve`
- `POST /api/v1/agents/:id/reject`
- `POST /api/v1/agents/:id/pause`
- `POST /api/v1/agents/:id/resume`
- `GET /api/v1/agents`
- `GET /api/v1/agents/:id/status`
- `GET /api/v1/agents/:id/tasks`
- `POST /api/v1/agents/tasks/create`
- `POST /api/v1/agents/tasks/:taskId/claim`
- `POST /api/v1/agents/tasks/:taskId/complete`
- `POST /api/v1/agents/votes/cast`
- `POST /api/v1/agents/votes/finalize`
- `POST /api/v1/agents/payments/record`
- `GET /api/v1/agents/payments/pending`

---

## 6) Event contract and hook taxonomy

### Hook naming standard
`domain.entity.action` (e.g. `chat.message.created`, `agent.task.completed`)

### Envelope
```json
{
  "event_id": "evt_...",
  "event_type": "chat.message.created",
  "at": "2026-03-31T00:00:00Z",
  "actor": { "type": "user|agent|system", "id": "..." },
  "trace_id": "trc_...",
  "payload": {},
  "risk": "low|medium|high|critical",
  "environment": "staging|production"
}
```

### Delivery policy
- At-least-once delivery with idempotency keys.
- Dead-letter queue for poison events.
- Replay endpoint for operational recovery.

---

## 7) Data architecture (Cloudflare D1 + local-first)

## 7.1 D1 database set
- `core.db`
- `chat.db`
- `training.db`
- `voice.db`
- `avatar.db`
- `agents.db`
- `routes.db`
- `tools.db`
- `audit.db`
- `telemetry.db`

## 7.2 Important SQL implementation correction
In SQLite/D1, define indexes with explicit `CREATE INDEX` statements (not inline `INDEX ...` clauses in `CREATE TABLE`).

### Example
```sql
CREATE TABLE IF NOT EXISTS business_apps (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  owner_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  config_json TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_business_apps_owner_id
  ON business_apps(owner_id);

CREATE INDEX IF NOT EXISTS idx_business_apps_created_at
  ON business_apps(created_at);
```

## 7.3 Mandatory metadata columns (where applicable)
`id, owner_id, project_id, environment, status, version, tags_json, trace_id, audit_id, created_at, updated_at`

---

## 8) Real implementation blueprint (Workers + Hono)

## 8.1 Router and middleware stack
1. request ID + trace injection
2. CORS policy by environment
3. authn (token/session)
4. authz (scope + mode checks)
5. rate limiting (KV token bucket)
6. idempotency guard (KV)
7. business route handlers
8. audit emission
9. unified error formatter

## 8.2 Recommended Worker entry (module syntax)
- One `fetch()` entry in gateway worker.
- Route internal domains by path and/or service binding.
- Use `ctx.waitUntil()` for non-blocking audit + event fanout.

## 8.3 Request context type (TypeScript)
Include:
- `requestId`
- `traceId`
- `actor`
- `scopes[]`
- `mode` (`staging|production`)
- `riskDecision`

---

## 9) Cloudflare API-driven operations (control plane)

Use Cloudflare API for automation in CI/CD and ops tooling.

### Core API groups to wire in
- Workers Scripts API (list/upload/settings/deployments)
- Workers Routes/Triggers API
- D1 API (create/query/export/import/time-travel restore)
- KV/R2 provisioning APIs where needed

### Example operational flows
1. Provision worker + bindings
2. Provision D1 db(s)
3. Run schema migrations
4. Deploy script versions
5. Attach/verify routes
6. Enable logs/observability settings

---

## 10) Wrangler configuration baseline (2026-ready)

```toml
name = "qhysync-gateway"
main = "src/index.ts"
compatibility_date = "2026-03-31"

[observability]
enabled = true

[assets]
directory = "./public"
binding = "ASSETS"

[[d1_databases]]
binding = "CORE_DB"
database_name = "qhysync-core"
database_id = "REPLACE_ME"

[[kv_namespaces]]
binding = "CACHE"
id = "REPLACE_ME"

[[r2_buckets]]
binding = "ARTIFACTS"
bucket_name = "qhysync-artifacts"

[vars]
APP_ENV = "staging"
```

> Note: For multi-worker architecture, keep one `wrangler.toml` per worker package and use service bindings between workers.

---

## 11) Security, compliance, and governance gates

### Required controls
- API token scope minimization
- JWT/session verification + rotation policy
- HMAC verification for incoming webhooks
- Replay protection (nonce + timestamp window)
- Sensitive route approvals in production
- Full audit memo generation for high-risk actions

### Voice-clone safety controls
- explicit consent flag
- watermark metadata
- local-only training default
- export lock unless policy override

---

## 12) Offline-first behavior model

### Browser local layer
- session cache
- pending command queue
- optimistic UI state
- local embeddings cache (optional)

### Sync/replay worker responsibilities
- conflict detection (revision/timestamp)
- deterministic merge rules
- replay with idempotency key
- failed event parking + user-visible remediation

---

## 13) Build order (execution plan)

### Sprint A (foundation)
- gateway-worker + auth/rate-limit/idempotency
- chat routes + chat.db
- tools registry core
- audit pipeline

### Sprint B (intelligence core)
- agent-manager routes + agents.db
- model-control routes
- training dataset ingest + queue pipeline

### Sprint C (multimodal)
- STT/TTS + keyword command parsing
- avatar state/lipsync endpoints
- voice safety/policy checks

### Sprint D (ops hardening)
- deployment worker
- route automation via CF API
- observability dashboards + tail strategy
- disaster recovery and replay drills

---

## 14) Production readiness checklist

- [ ] Per-route scope matrix complete
- [ ] D1 migrations tested locally and remote
- [ ] All writes idempotent or deduplicated
- [ ] Webhook signatures verified
- [ ] Audit trails generated for policy routes
- [ ] Logs enabled + sampled correctly
- [ ] Rollback playbooks tested
- [ ] Staging/production separation enforced

---

## 15) Cloudflare product deep-dive mapping (expanded)

This section adds a product-by-product implementation map so each QhySync module has a concrete Cloudflare primitive.

### 15.1 Workers + Routes + workers.dev
- Use `workers.dev` as a fast integration stage for internal validation before DNS route cutover.
- Use custom domain routes for production traffic isolation:
  - `api.<domain>` for API gateway,
  - `app.<domain>` for PWA shell,
  - `events.<domain>` for webhook ingress.
- Apply route-level split to keep browser/app and API concerns separate.

### 15.2 Pages + Workers hybrid
- Pages for UI previews/branch deploys.
- Workers for API, auth, orchestration, and edge middleware.
- Service bindings from edge API worker to backend workers keep internal traffic private and typed.

### 15.3 Durable Objects placement
Durable Objects are the preferred coordination primitive for:
- live chat session rooms,
- multi-user workspace cursors,
- streaming agent-run status channels,
- voice call session state,
- centralized command queue arbitration.

Use hibernation-aware patterns for websocket workloads so idle sessions do not continuously accrue execution costs.

### 15.4 Queues + Workflows split
- **Queues**: high-throughput event ingestion and retry buffering.
- **Workflows**: durable multi-step orchestration (approval gates, long-running training/eval jobs, deployment runbooks).

Use both together: queue message triggers workflow instance; workflow emits queue events for fanout.

### 15.5 Hyperdrive use
Use Hyperdrive for any external SQL source that remains outside D1 (e.g., legacy analytics or billing DB), while keeping edge latency acceptable.

### 15.6 Browser Rendering integration
Add browser rendering workers for:
- UI screenshot capture for QA bots,
- docs ingest snapshots,
- visual regression checks in staging,
- webpage-to-image evidence in audit memos.

### 15.7 AI stack extension
- Workers AI for low-latency inference.
- AI Gateway for traffic control, analytics, fallback policy, caching policy.
- Vectorize for semantic retrieval over docs/notes/session memory.

---

## 16) Storage decision matrix: D1 vs KV vs Durable Objects vs R2 vs Vectorize

| Data need | Best service | Why |
|---|---|---|
| Relational entities, joins, audit records | D1 | SQL schema + transactional query model |
| Ephemeral config, edge cache, idempotency keys | KV | Globally distributed key-value reads |
| Strongly consistent session coordinator | Durable Objects | Single-threaded state authority per object key |
| Files/media/checkpoints/datasets | R2 | Object storage economics and scale |
| Embeddings + similarity search | Vectorize | Native vector index/search pipeline |

### 16.1 QhySync mapping
- `chat messages`: D1 (+ DO for live stream state)
- `tool rate tokens`: KV
- `voice clips and datasets`: R2
- `semantic memory`: Vectorize
- `room/session arbitration`: Durable Objects

---

## 17) Expanded tools and components catalog

## 17.1 Platform components
- API gateway component
- identity/session component
- risk-policy decision component
- worker registry component
- route/schema contract registry
- secrets and key rotation component
- observability exporter
- replay and incident forensics toolkit

## 17.2 AI and retrieval components
- prompt registry
- model capability descriptor
- inference policy router
- evaluation benchmark runner
- embedding pipeline orchestrator
- rerank component
- source citation linker

## 17.3 Voice-avatar components
- wakeword detector
- VAD controller
- command parser
- turn manager (barge-in aware)
- viseme scheduler
- gesture blending controller
- emotion/tone policy mapper

## 17.4 DevOps components
- migration runner
- synthetic load test component
- deployment promotion gate
- rollback planner
- post-deploy verification component

---

## 18) Worker manifest template pack (expanded)

### 18.1 Base manifest
```json
{
  "workerId": "gateway-worker",
  "version": "1.0.0",
  "routes": ["/api/v1/*"],
  "serviceBindings": ["chat-worker", "agent-manager-worker"],
  "d1": ["core.db", "audit.db"],
  "kv": ["CACHE", "LIMITS"],
  "queuesProducers": ["events-main"],
  "queuesConsumers": ["events-deadletter"],
  "r2": ["ARTIFACTS"],
  "scopes": ["gateway.read", "gateway.write"],
  "riskClass": "high",
  "requiresApproval": true
}
```

### 18.2 Route contract template
```json
{
  "routeId": "chat.send.v1",
  "method": "POST",
  "path": "/api/v1/chat/send",
  "requestSchema": "ChatSendRequest",
  "responseSchema": "ChatSendResponse",
  "idempotency": "optional",
  "auth": { "required": true, "scopes": ["chat.write"] },
  "rateLimit": { "bucket": "chat_write", "rpm": 120 },
  "eventsOut": ["chat.message.created", "chat.response.completed"]
}
```

### 18.3 Workflow contract template
```json
{
  "workflowId": "training-job-lifecycle",
  "steps": [
    "validate_dataset",
    "prepare_chunks",
    "run_training",
    "run_eval",
    "publish_metrics"
  ],
  "retryPolicy": { "maxRetries": 5, "backoff": "exponential" },
  "approvalSteps": ["publish_metrics"],
  "timeouts": { "total": "72h" }
}
```

---

## 19) API and realtime expansion

### 19.1 Realtime channels (WebSockets over DO)
- `/ws/chat/:sessionId`
- `/ws/agents/:taskId`
- `/ws/voice/:callId`
- `/ws/deploy/:deploymentId`

### 19.2 Streaming REST additions
- `GET /api/v1/events/stream` (SSE)
- `GET /api/v1/agents/:id/live`
- `GET /api/v1/training/jobs/:id/stream`

### 19.3 Admin and control routes
- `POST /api/v1/admin/routes/reload`
- `POST /api/v1/admin/cache/invalidate`
- `POST /api/v1/admin/replay/:traceId`
- `GET /api/v1/admin/incidents/:incidentId`

---

## 20) Security and secrets runbook (expanded)

### 20.1 Secret classes
- platform secrets (CF API token, webhook signing keys)
- service secrets (internal service bearer tokens)
- environment secrets (staging/prod separation)
- one-time operation tokens (deployment approvals)

### 20.2 Enforcement rules
- no plaintext secrets in D1/KV.
- rotate high-privilege secrets on schedule.
- enforce least-privilege token scopes.
- split CI deploy token from runtime integration token.

### 20.3 Webhook hardening
- verify HMAC signature
- enforce timestamp freshness window
- prevent replay with nonce cache
- write verification outcome to audit ledger

---

## 21) Observability and SLO model

### 21.1 Core telemetry dimensions
- `trace_id`, `request_id`, `actor_id`, `route_id`, `worker_id`, `risk_class`, `environment`

### 21.2 Golden signals
- latency (p50, p95, p99)
- request error rate
- queue lag/dead-letter depth
- workflow success/timeout rate
- D1 query latency
- vector retrieval latency

### 21.3 Target SLO examples
- API availability: 99.9%
- p95 gateway latency: < 250ms for cacheable reads
- queue retry success within 15m: > 99%

---

## 22) PWA and offline hardening details

### 22.1 Static asset routing modes
- SPA mode for navigation fallbacks to `index.html`.
- run-worker-first patterns for API and dynamic paths.
- custom 404 behavior per app zone.

### 22.2 Offline queue object shape
```json
{
  "queue_id": "q_...",
  "op": "tool.run",
  "payload": {},
  "idempotency_key": "idem_...",
  "created_at": 1767225600,
  "retry_count": 0,
  "last_error": null
}
```

### 22.3 Sync conflict strategy
- last-write-wins only for low-risk profile settings.
- semantic merge for documents/notes.
- approval queue for policy-sensitive state.

---

## 23) Cloudflare API automation matrix

| Lifecycle task | Preferred API/Tooling |
|---|---|
| Provision Worker script | Cloudflare API (Workers) + Wrangler |
| Configure custom routes | Cloudflare API routes endpoints |
| Manage D1 databases | Wrangler + D1 API |
| Manage Browser Rendering jobs | Browser Rendering REST API |
| Trigger deployment promotion | CI workflow calling Cloudflare API |
| Pull operational logs | Workers observability + tail |

### 23.1 CI pipeline stages
1. lint + typecheck
2. unit/integration tests
3. schema migration dry-run
4. deploy to staging workers.dev route
5. smoke tests
6. promote to custom domain route
7. post-deploy audit snapshot

---

## 24) Expanded implementation phases

### Phase 0 — docs, contracts, and standards
- finalize schemas, manifests, route contracts, and policy matrix

### Phase 1 — gateway and chat spine
- gateway worker + chat worker + D1/KV + observability

### Phase 2 — async and orchestration
- queues + workflows + DO realtime streams

### Phase 3 — AI and retrieval
- workers AI + AI gateway + vectorize + eval tracks

### Phase 4 — multimodal
- STT/TTS/STS + avatar + keyword command engine

### Phase 5 — production maturity
- incident automation, audit replay, DR runbooks, cost optimization

---

## 25) Final positioning

QhySync is not just a chat assistant. This spec defines a **local-first AI operating system** with:
- Cloudflare-native edge backend services,
- explicit storage-role boundaries (D1/KV/DO/R2/Vectorize),
- governed autonomous agents and durable workflows,
- multimodal voice/avatar execution,
- and a practical phased path from MVP to production-grade platform.

This is the implementation-ready bridge between your strategic vision and an operable, testable backend ecosystem.

---

## 26) Cloudflare documentation anchors used for this spec

### Core platform
- Workers overview: https://developers.cloudflare.com/workers/
- Wrangler CLI: https://developers.cloudflare.com/workers/wrangler/
- Workers routes: https://developers.cloudflare.com/workers/configuration/routing/routes/
- workers.dev routes: https://developers.cloudflare.com/workers/configuration/routing/workers-dev/

### Full-stack and PWA delivery
- Static assets routing: https://developers.cloudflare.com/workers/static-assets/routing/
- SPA routing mode: https://developers.cloudflare.com/workers/static-assets/routing/single-page-application/
- Pages docs: https://developers.cloudflare.com/pages/

### Data and state
- D1 docs: https://developers.cloudflare.com/d1/
- D1 get started: https://developers.cloudflare.com/d1/get-started/
- D1 API query endpoint: https://developers.cloudflare.com/api/resources/d1/subresources/database/methods/query/
- D1 index guidance: https://developers.cloudflare.com/d1/build-with-d1/use-indexes/
- KV docs: https://developers.cloudflare.com/kv/
- R2 docs: https://developers.cloudflare.com/r2/
- Durable Objects overview: https://developers.cloudflare.com/durable-objects/
- Durable Objects concepts: https://developers.cloudflare.com/durable-objects/concepts/what-are-durable-objects/
- Durable Objects websocket hibernation best practices: https://developers.cloudflare.com/durable-objects/best-practices/websockets/
- Queues docs: https://developers.cloudflare.com/queues/
- Hyperdrive docs: https://developers.cloudflare.com/hyperdrive/

### AI and search
- Workers AI: https://developers.cloudflare.com/workers-ai/
- Workers AI with Wrangler: https://developers.cloudflare.com/workers-ai/get-started/workers-wrangler/
- Vectorize docs: https://developers.cloudflare.com/vectorize/
- AI Gateway docs: https://developers.cloudflare.com/ai-gateway/

### Realtime, workflows, background
- Workflows docs: https://developers.cloudflare.com/workflows/
- Workflows get started: https://developers.cloudflare.com/workflows/get-started/guide/
- Workflows Workers API: https://developers.cloudflare.com/workflows/build/workers-api/
- Cron triggers: https://developers.cloudflare.com/workers/configuration/cron-triggers/
- WebSockets examples: https://developers.cloudflare.com/workers/examples/websockets/

### Networking and security
- Bindings overview: https://developers.cloudflare.com/workers/runtime-apis/bindings/
- Service bindings: https://developers.cloudflare.com/workers/runtime-apis/bindings/service-bindings/
- Secrets: https://developers.cloudflare.com/workers/configuration/secrets/
- Observability: https://developers.cloudflare.com/workers/observability/
- Workers logs: https://developers.cloudflare.com/workers/observability/logs/workers-logs/
- Real-time logs: https://developers.cloudflare.com/workers/observability/logs/real-time-logs/
- Browser Rendering docs: https://developers.cloudflare.com/browser-rendering/
- Browser Rendering screenshot API: https://developers.cloudflare.com/browser-rendering/rest-api/screenshot-endpoint/

### APIs and runtime reference
- Cloudflare API docs: https://developers.cloudflare.com/api/
- Workers API resources: https://developers.cloudflare.com/api/resources/workers/
- Workers runtime APIs: https://developers.cloudflare.com/workers/runtime-apis/

---

## 27) Complete build automation and manifests (enhanced)

This section operationalizes the architecture with concrete CI/CD, manifest packs, and bootstrap commands.

### 27.1 GitHub Actions pipeline (implementation-ready)

> Recommendation: keep workflow as YAML in `.github/workflows/qhysync-ci-cd.yml`.

```yaml
name: QhySync AI Studio CI/CD Pipeline

on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'wrangler.toml'
      - 'package.json'
      - '.github/workflows/**'
  pull_request:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      environment:
        description: Target environment
        required: true
        default: staging
        type: choice
        options:
          - staging
          - production

jobs:
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx eslint "src/**/*.ts"
      - run: npx tsc --noEmit
      - run: npx prettier --check "src/**/*.ts"

  test:
    name: Run Tests
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage

  build:
    name: Build All Workers
    runs-on: ubuntu-latest
    needs: [lint, test]
    strategy:
      matrix:
        worker:
          - gateway
          - auth
          - apps-registry
          - keys
          - hooks
          - events
          - sync
          - audit
          - chat
          - model-control
          - training
          - eval
          - agent-manager
          - agent-task
          - agent-vote
          - agent-pay
          - voice-stt
          - voice-tts
          - voice-sts
          - keyword
          - avatar
          - obsidian
          - docs
          - embeddings
          - search
          - code
          - schema
          - test
          - deploy
          - telemetry
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx wrangler deploy --dry-run --env ${{ matrix.worker }}
      - uses: actions/upload-artifact@v4
        with:
          name: worker-${{ matrix.worker }}
          path: .wrangler

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop' || github.event.inputs.environment == 'staging'
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: bash scripts/deploy-staging.sh
      - run: npx wrangler d1 migrations apply CORE_DB --env staging

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main' || github.event.inputs.environment == 'production'
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: bash scripts/deploy-production.sh
      - run: npx wrangler d1 migrations apply CORE_DB --env production
```

### 27.2 Worker manifest pack (30 workers)

#### Core infrastructure
1. gateway-worker
2. auth-worker
3. apps-registry-worker
4. keys-worker
5. hooks-worker
6. events-worker
7. sync-worker
8. audit-worker

#### AI and training
9. chat-worker
10. model-control-worker
11. training-worker
12. eval-worker

#### Agents and workforce
13. agent-manager-worker
14. agent-task-worker
15. agent-vote-worker
16. agent-pay-worker

#### Voice and avatar
17. voice-stt-worker
18. voice-tts-worker
19. voice-sts-worker
20. keyword-worker
21. avatar-worker

#### Knowledge and docs
22. obsidian-worker
23. docs-worker
24. embeddings-worker
25. search-worker

#### Dev and deployment
26. code-worker
27. schema-worker
28. test-worker
29. deploy-worker
30. telemetry-worker

### 27.3 Database manifest pack (15 logical databases)

1. CORE_DB
2. CHAT_DB
3. TRAINING_DB
4. VOICE_DB
5. AVATAR_DB
6. AGENTS_DB
7. PROJECTS_DB
8. ROUTES_DB
9. HOOKS_DB
10. AUDIT_DB
11. OBSIDIAN_DB
12. WALLET_DB
13. MODELS_DB
14. TELEMETRY_DB
15. TOOLS_DB

### 27.4 Route catalog pack (expanded categories)

- `/api/v1/gateway/*`
- `/api/v1/auth/*`
- `/api/v1/apps/*`
- `/api/v1/keys/*`
- `/api/v1/hooks/*`
- `/api/v1/events/*`
- `/api/v1/sync/*`
- `/api/v1/audit/*`
- `/api/v1/chat/*`
- `/api/v1/models/*`
- `/api/v1/training/*`
- `/api/v1/evals/*`
- `/api/v1/agents/*`
- `/api/v1/tasks/*`
- `/api/v1/votes/*`
- `/api/v1/payments/*`
- `/api/v1/voice/stt`
- `/api/v1/voice/tts`
- `/api/v1/voice/sts`
- `/api/v1/commands/*`
- `/api/v1/avatar/*`
- `/api/v1/avatar/render`
- `/api/v1/avatar/lipsync`
- `/api/v1/obsidian/*`
- `/api/v1/docs/*`
- `/api/v1/embeddings/*`
- `/api/v1/search/*`
- `/api/v1/code/*`
- `/api/v1/schema/*`
- `/api/v1/test/*`
- `/api/v1/deploy/*`
- `/api/v1/telemetry/*`

### 27.5 Webhook catalog (starter set)

- `gateway.request.received`
- `gateway.request.processed`
- `gateway.response.sent`
- `gateway.error.occurred`
- `gateway.rate.limit.exceeded`
- `auth.session.created`
- `auth.session.expired`
- `auth.token.verified`
- `auth.token.revoked`
- `auth.failed.login`
- `training.job.started`
- `training.job.completed`
- `training.job.failed`
- `training.eval.run`
- `agent.task.assigned`
- `agent.task.completed`
- `agent.vote.cast`
- `agent.vote.finalized`
- `agent.payment.recorded`
- `stt.session.started`
- `stt.session.completed`
- `tts.job.completed`
- `voice.clone.started`
- `voice.clone.completed`
- `avatar.render.started`
- `avatar.render.completed`
- `avatar.lip.synced`
- `avatar.gesture.played`

### 27.6 Starter schema pack (logical domains)

- Initial/Core schema
- Chat schema
- Training schema
- Voice schema
- Avatar schema
- Agents schema
- Projects schema
- Routes schema
- Hooks schema
- Audit schema
- Obsidian schema
- Wallet schema
- Models schema
- Telemetry schema
- Tools schema

### 27.7 Quick start commands (bootstrap)

```bash
# scaffold
npx create-cloudflare@latest qhysync-ai-studio
cd qhysync-ai-studio

# create D1 databases (example subset)
npx wrangler d1 create core-db
npx wrangler d1 create chat-db
npx wrangler d1 create training-db
npx wrangler d1 create voice-db
npx wrangler d1 create agents-db

# KV namespaces
npx wrangler kv namespace create RATE_LIMIT
npx wrangler kv namespace create CACHE
npx wrangler kv namespace create SESSIONS

# R2 buckets
npx wrangler r2 bucket create models-bucket
npx wrangler r2 bucket create voice-bucket
npx wrangler r2 bucket create artifacts-bucket

# migrations
npx wrangler d1 migrations create CORE_DB init_core
npx wrangler d1 migrations apply CORE_DB --local
npx wrangler d1 migrations apply CORE_DB --remote

# deploy
npx wrangler deploy
```

### 27.8 Dashboard links guidance (security note)

Do **not** hardcode account-specific dashboard URLs in public docs. Use generic links:
- Workers & Pages: `https://dash.cloudflare.com/?to=/:account/workers-and-pages`
- D1: `https://dash.cloudflare.com/?to=/:account/d1`
- KV: `https://dash.cloudflare.com/?to=/:account/kv`
- R2: `https://dash.cloudflare.com/?to=/:account/r2`

### 27.9 Build automation acceptance criteria

- Every PR runs lint, test, dry-run build.
- Deploy jobs are environment-gated.
- Production deploy requires protected environment approval.
- D1 migrations run in CI with rollback plan documented.
- Artifacts retained for post-failure forensics.


### 27.10 Git command packs (ecosystem use-case specific)

Use these command packs to standardize collaboration across the QhySync worker ecosystem.

#### A) Bootstrap repository and baseline branches
```bash
git init
git checkout -b main
git checkout -b develop
git push -u origin main
git push -u origin develop
```

#### B) Feature development for a single worker (example: chat-worker)
```bash
git checkout develop
git pull --rebase origin develop
git checkout -b feat/chat-worker-streaming-v1
# edit files under workers/chat-worker/**
git add workers/chat-worker docs/qhysync-cloudflare-unified-router-spec.md
git commit -m "feat(chat-worker): add streaming controls and route contracts"
git push -u origin feat/chat-worker-streaming-v1
```

#### C) Cross-worker contract update (gateway + auth + tools)
```bash
git checkout develop
git pull --rebase origin develop
git checkout -b feat/contracts-gateway-auth-tools-v2
# update shared schemas/contracts
git add contracts/ workers/gateway-worker workers/auth-worker workers/tools-worker
git commit -m "feat(contracts): v2 scopes and authz envelope across core workers"
git push -u origin feat/contracts-gateway-auth-tools-v2
```

#### D) Database migration workflow (D1)
```bash
git checkout develop
git checkout -b chore/d1-migrations-training-db-004
# create migration files under migrations/training-db/
git add migrations/training-db
git commit -m "chore(training-db): add 004 checkpoint and eval indexes"
git push -u origin chore/d1-migrations-training-db-004
```

#### E) Release branch for production cut
```bash
git checkout develop
git pull --rebase origin develop
git checkout -b release/2026-04-qhysync-platform
# bump versions/changelog/release notes
git add .
git commit -m "chore(release): cut 2026-04 platform release"
git push -u origin release/2026-04-qhysync-platform
```

#### F) Hotfix flow (production incident)
```bash
git checkout main
git pull --rebase origin main
git checkout -b hotfix/gateway-rate-limit-regression
# patch critical issue
git add workers/gateway-worker
git commit -m "fix(gateway): restore rate-limit guard for anonymous burst traffic"
git push -u origin hotfix/gateway-rate-limit-regression
```

#### G) Rollback tagging and deployment traceability
```bash
git checkout main
git pull --rebase origin main
git tag -a v2026.04.0 -m "QhySync platform release v2026.04.0"
git push origin v2026.04.0
# if rollback needed, redeploy prior tag
git tag -l "v2026.*"
```

#### H) Monorepo selective commit hygiene
```bash
# review only worker-specific changes
git status
git diff -- workers/voice-stt-worker workers/voice-tts-worker
# stage exact hunks for clean PR scope
git add -p workers/voice-stt-worker workers/voice-tts-worker
```

#### I) Security and secrets policy updates
```bash
git checkout develop
git checkout -b chore/security-token-rotation-policy
git add docs/security/ policies/
git commit -m "chore(security): rotate token policy and secret handling SOP"
git push -u origin chore/security-token-rotation-policy
```

#### J) Documentation sync for architecture governance
```bash
git checkout develop
git checkout -b docs/spec-sync-worker-manifests
git add Qhy-Projects/docs/qhysync-cloudflare-unified-router-spec.md
git commit -m "docs(spec): sync worker/database/route manifests with latest platform changes"
git push -u origin docs/spec-sync-worker-manifests
```

