(empty)
# REST API Automation Sample

Lightweight Robot Framework based REST API automation sample. The project contains Robot tests, supporting keywords/resources, environment-specific variable files and convenience tasks to run smoke and regression suites locally or inside Docker. It also integrates with ReportPortal for test reporting.

## Contents

- `tests/` - Robot Framework test suites (e.g. `001_health.robot`, `002_login.robot`, ...)
- `resources/` - Robot resources and keyword implementations
- `data/` - JSON or variable files used by tests
- `results/` - Generated test run outputs
- `reports/` and `output/allure` - report artifacts (Allure / ReportPortal attachments)
- `tasks.py` - Invoke tasks to run tests, lint, and clean directories
- `requirements.txt` - Python dependencies
- `Dockerfile`, `docker-compose.yml` - containerized test runner

## Quick overview / contract

- Inputs: Robot test files under `tests/` and optional env files (`.env`, `.env.staging`, `.env.prod`).
- Outputs: Test results written to `results/<suite>/<timestamp>/` and attachments in `output/` and `reports/`.
- Success criteria: `inv smoke` and `inv regression` exit with 0 and produce report artifacts.

## Prerequisites

- Python 3.12 (or a compatible 3.x) and pip
- Docker & docker-compose (optional, for containerized runs)
- Optional: ReportPortal server and API key if you want to publish results

Install project dependencies:

```bash
python -m pip install -r requirements.txt
```

## Running tests locally (recommended)

This project uses `invoke` tasks defined in `tasks.py` to run Robot Framework tests with ReportPortal integration.

- Run all tests:

```bash
inv test
```

- Run smoke tests only:

```bash
inv smoke
```

- Run regression (full):

```bash
inv regression
```

- Run regression for a specific suite name (if defined):

```bash
inv regression --suite=your_suite_name
```

- Run tests for a specific environment (loads `.env.staging` or `.env.prod`):

```bash
inv staging
inv prod
```

Notes:
- `tasks.py` builds an output directory under `results/<subdir>/<timestamp>/` and constructs ReportPortal launch metadata from environment variables (`RP_API_KEY`, `RP_ENDPOINT`, `RP_PROJECT`, `TEST_ENV`, `GIT_BRANCH`).
- If important environment variables are missing, the tasks will print warnings; set them in a `.env` file or in your shell.

## Running inside Docker / CI

The repository includes a `Dockerfile` and `docker-compose.yml` intended to run the test container. Before using Docker Compose, provide an `.env` file with the necessary environment variables (endpoint, ReportPortal settings, etc.). Example variables used by the compose file:

- `ENDPOINT` - API base URL under test
- `RP_ENDPOINT`, `RP_API_KEY`, `RP_PROJECT` - ReportPortal connection
- `TEST_ENV`, `GIT_BRANCH`, `DOCKER_NETWORK`, `TEST_CONTAINER_NAME`

To run with docker-compose (from project root):

```bash
docker compose up --build
# or (older docker-compose syntax)
docker-compose up --build
```

The compose service named `tester` runs `inv smoke` then `inv regression` in sequence (see `docker-compose.yml`).

## Project structure and how tests are organized

- `tests/*.robot` are the main test cases. Each test loads `resources/` and data from `data/`.
- `resources/keywords/` contains higher-level Robot keywords (e.g., `controller.resource`).
- `data/*.json` hold endpoint paths, expected payloads and other test inputs.
- Results and report artifacts are stored in `results/`, `output/`, and `reports/`.

## ReportPortal integration

The test runner includes the `robotframework_reportportal` listener and propagates ReportPortal variables via `tasks.py`:

- `RP_API_KEY` — API key for ReportPortal
- `RP_ENDPOINT` — URL of your ReportPortal server
- `RP_PROJECT` — ReportPortal project name
- `RP_LAUNCH`, `RP_LAUNCH_ATTRIBUTES` — constructed automatically by `tasks.py`

Set these in your `.env` or CI environment to publish test runs to ReportPortal.

## Linting and cleanup

- Lint: `inv lint` (runs `flake8` and `black --check`)
- Clean results: `inv clean` (removes the `results/` directory)

## Troubleshooting

- If tests cannot reach the API, verify `ENDPOINT` and network access.
- If ReportPortal uploads fail, check `RP_API_KEY` and `RP_ENDPOINT` values.

## Contributing

Feel free to open issues or submit pull requests. Keep tests deterministic and add new data files under `data/` with clear names.

## License

This repository does not include a license file. Add one if you intend to make the project public.

---
Generated: a concise README for running Robot Framework REST API tests with optional ReportPortal reporting.
