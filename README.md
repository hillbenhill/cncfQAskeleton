# Sysdig Starter (GitHub Actions)

This repo demonstrates:
- Image build + vulnerability gating with `sysdig-cli-scanner` (policy-based CI fail).
- API smoke tests in Python using the Sysdig SDK.
- UI E2E tests with Playwright (opt-in).
- (Optional) Runtime detection trigger + Secure API poll.

## Setup

1. Create repository **secrets** (Settings → Secrets and variables → Actions):
   - `SYSDIG_API_TOKEN` – your bearer token (user or service account).
   - `SYSDIG_API_URL` – regional API base, e.g. `https://api.us1.sysdig.com`.

   Optional for UI tests (only if non-SSO credentials are available):
   - `E2E_SYS_DIG_UI=1`, `SYSDIG_UI_URL`, `SYSDIG_USERNAME`, `SYSDIG_PASSWORD`.

2. Push to main or open a PR. The workflow will:
   - Build and push a demo image to GHCR.
   - Scan the image with Sysdig CLI scanner and **fail** if the policy gate blocks.
   - Run **Pytest API smoke** via the Sysdig Python SDK.
   - Run **Playwright tests** (UI test runs only if enabled).

3. (Optional) Runtime simulation
   - Uncomment the `runtime-sim` job in `.github/workflows/ci.yml`.
   - Add a `KUBECONFIG` secret (base64 of your kubeconfig) so the job can `kubectl apply`.
   - Ensure your cluster is connected to Sysdig Secure and detections are active.

## Local runs

**API tests**
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r api-python/requirements.txt
export SYSDIG_API_TOKEN=...
export SYSDIG_API_URL=https://api.us1.sysdig.com
pytest -q api-python/tests
```

**Playwright**
```bash
cd e2e
npm ci
npx playwright install --with-deps
npx playwright test tests/health.spec.ts
# Optional UI test
export E2E_SYS_DIG_UI=1 SYSDIG_UI_URL='https://<your-tenant-url>' SYSDIG_USERNAME='...' SYSDIG_PASSWORD='...'
npx playwright test tests/secure_vuln_pipeline.spec.ts
```

**Build & run the demo Docker image locally**
```bash
docker build -t sysdig-starter:local .
docker run -p 8000:8000 --rm sysdig-starter:local
# open http://localhost:8000
```

## Notes
- Change the scanner policy name in CI (e.g., `--policy "Block Critical CVEs"`) to match your org’s gate.
- Replace the demo static app under `app/` with your real service and adjust the `CMD`/healthcheck accordingly.
- For policy-as-code (alerts/dashboards), consider the Sysdig Terraform provider in a follow-up.
