import os
import shutil
from datetime import datetime
from invoke import task
from dotenv import load_dotenv

# Load biến môi trường từ .env
load_dotenv()

ROOT = os.path.dirname(__file__)
PYTHON_PATH = ROOT
RESULTS_DIR = os.path.join(ROOT, "results")
PROJECT_NAME = os.path.basename(ROOT)
DEFAULT_SUITE = f"{PROJECT_NAME}.tests"


def _timestamp() -> str:
    """Trả về timestamp định dạng yyyy-mm-dd_HH-MM-SS"""
    return datetime.now().strftime("%Y-%m-%d_%H-%M-%S")


def _run_robot(c, opts: str, output_subdir: str, suite: str | None = None):
    """
    Helper để chạy Robot Framework với PYTHONPATH và outputdir có timestamp
    """
    outdir = os.path.join(RESULTS_DIR, output_subdir, _timestamp())
    tests = DEFAULT_SUITE if not suite else f"{DEFAULT_SUITE}.{suite}"

    cmd = (
        f"PYTHONPATH={PYTHON_PATH} "
        f"robot --outputdir {outdir} {opts} --suite {tests} ."
    )
    c.run(cmd, pty=True)


@task(help={"tags": "Optional: filter tests by tags (comma-separated)"})
def test(c, tags=None):
    """Run all tests, optional --tags"""
    opts = f"--include {tags} " if tags else ""
    _run_robot(c, opts, "all")


@task
def smoke(c):
    """Run only smoke tests"""
    _run_robot(c, "--include Smoke", "smoke")


@task(help={"suite": "Optional: run specific suite"})
def regression(c, suite=None):
    """
    Run regression tests.
    - Full regression: inv regression
    - Partial regression (1 suite): inv regression --suite=tests/user
    """
    opts = "--include Regression --exclude Smoke"
    output_dir = f"regression/{suite}" if suite else "regression/full"
    _run_robot(c, opts, output_subdir=output_dir, suite=suite)


def _env_run(c, env_file: str, output_dir: str):
    """Helper để chạy test với biến môi trường riêng"""
    _run_robot(c, f"--variablefile {env_file}", output_dir)


@task
def staging(c):
    """Run tests with staging environment variables"""
    _env_run(c, ".env.staging", "staging")


@task
def prod(c):
    """Run tests with production environment variables"""
    _env_run(c, ".env.prod", "prod")


@task(help={"open_report": "Open report in browser after generating"})
def allure(c, open_report=False):
    """Generate Allure report, optionally open browser"""
    report_dir = os.path.join(RESULTS_DIR, "allure-report")
    history_dir = os.path.join(report_dir, "history")

    c.run(f"allure generate {RESULTS_DIR} --clean -o {report_dir}", pty=True)

    if os.path.exists(history_dir):
        shutil.copytree(history_dir, os.path.join(report_dir, "history"), dirs_exist_ok=True)

    if open_report:
        c.run(f"allure open {report_dir}", pty=True)


@task
def lint(c):
    """Run linting checks (flake8, black --check)"""
    c.run("flake8 .", pty=True)
    c.run("black --check .", pty=True)


@task
def clean(c):
    """Clean results directory"""
    if os.path.exists(RESULTS_DIR):
        shutil.rmtree(RESULTS_DIR)
        print(f"Deleted {RESULTS_DIR}")
    else:
        print("No results directory found")
