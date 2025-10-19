import os
import re
import shutil
from datetime import datetime
from invoke import task
from dotenv import load_dotenv

# === Load biến môi trường từ .env ===
load_dotenv()

ROOT = os.path.dirname(__file__)
PYTHON_PATH = ROOT
RESULTS_DIR = os.path.join(ROOT, "results")
REPORTS_DIR = os.path.join(ROOT, "reports")
PROJECT_NAME = os.path.basename(ROOT)
DEFAULT_SUITE = f"{PROJECT_NAME}.tests"

# === Report Portal Config ===
RP_API_KEY = os.getenv("RP_API_KEY")
RP_ENDPOINT = os.getenv("RP_ENDPOINT")
RP_PROJECT = os.getenv("RP_PROJECT")
RP_TEST_ENV = os.getenv("TEST_ENV", "local")
RP_GIT_BRANCH = os.getenv("GIT_BRANCH", "main")

# === Helper Functions ===
def _timestamp() -> str:
    """Trả về timestamp định dạng yyyy-mm-dd_HH-MM-SS"""
    return datetime.now().strftime("%Y-%m-%d_%H-%M-%S")


def _safe_env(name: str, value: str | None):
    """Cảnh báo nếu thiếu biến môi trường quan trọng"""
    if not value:
        print(f"⚠️  Missing env: {name}")
    return value or "undefined"


def _ensure_dir(path: str):
    """Đảm bảo thư mục tồn tại"""
    os.makedirs(path, exist_ok=True)


def _build_rp_args(output_subdir: str, suite: str | None, timestamp: str) -> tuple[str, str, str]:
    """Tạo argument cho ReportPortal"""
    safe_output = re.sub(r"[/\s]+", "_", output_subdir)
    safe_suite = re.sub(r"[/\s]+", "_", suite or "all")
    rp_launch_name = f"{safe_output}_{safe_suite}_{timestamp}"

    rp_launch_attributes = (
        f"project:{RP_PROJECT} "
        f"suite:{suite or 'all'} "
        f"env:{RP_TEST_ENV} "
        f"branch:{RP_GIT_BRANCH} "
        f"build:{timestamp}"
    )
    return (
        f"--listener robotframework_reportportal.listener "
        f"--variable RP_API_KEY:{_safe_env('RP_API_KEY', RP_API_KEY)} "
        f"--variable RP_ENDPOINT:{_safe_env('RP_ENDPOINT', RP_ENDPOINT)} "
        f"--variable RP_LAUNCH:{rp_launch_name} "
        f"--variable RP_PROJECT:{_safe_env('RP_PROJECT', RP_PROJECT)} "
        f"--variable RP_LAUNCH_ATTRIBUTES:\"{rp_launch_attributes}\""
    ), rp_launch_name, rp_launch_attributes


def _run_robot(c, opts: str, output_subdir: str, suite: str | None = None):
    """
    Helper chạy Robot Framework với PYTHONPATH, outputdir có timestamp,
    tích hợp Allure và ReportPortal qua --variable.
    """
    timestamp = _timestamp()
    outdir = os.path.join(RESULTS_DIR, output_subdir, timestamp)
    allure_results_dir = os.path.join(outdir, "allure-results")
    allure_report_dir = os.path.join(REPORTS_DIR, "allure-report", output_subdir, timestamp)

    _ensure_dir(allure_results_dir)
    _ensure_dir(allure_report_dir)

    tests = DEFAULT_SUITE if not suite else f"{DEFAULT_SUITE}.{suite}"

    # Tạo ReportPortal arguments
    rp_args, rp_launch_name, rp_launch_attributes = _build_rp_args(output_subdir, suite, timestamp)

    # Build robot command
    cmd = (
        f"PYTHONPATH={PYTHON_PATH} "
        f"robot --outputdir {outdir} "
        f"--listener allure_robotframework:{allure_results_dir} "
        f"{rp_args} "
        f"{opts} --suite {tests} ."
    )

    print(f"\n🚀 Running Robot tests: {tests}")
    print(f"📁 Output: {outdir}")
    print(f"📊 ReportPortal Launch: {rp_launch_name}")
    print(f"🏷️  Attributes: {rp_launch_attributes}\n")

    # Run tests
    c.run(cmd, pty=True)

    # Generate Allure report
    try:
        c.run(f"allure generate {allure_results_dir} -o {allure_report_dir}", pty=True)
        print(f"✅ Allure report generated: {allure_report_dir}")
    except Exception as e:
        print(f"⚠️  Failed to generate Allure report: {e}")


# === Tasks ===

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
    """Run regression tests"""
    opts = "--include Regression --exclude Smoke"
    output_dir = f"regression/{suite}" if suite else "regression/full"
    _run_robot(c, opts, output_subdir=output_dir, suite=suite)


def _env_run(c, env_file: str, output_dir: str):
    """Helper để chạy test với biến môi trường riêng"""
    load_dotenv(env_file, override=True)
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
    """Mở report Allure gần nhất"""
    report_base = os.path.join(REPORTS_DIR, "allure-report")
    if not os.path.exists(report_base):
        print("⚠️  No allure-report directory found")
        return

    latest_report_dir = max(
        (os.path.join(report_base, d) for d in os.listdir(report_base)),
        key=os.path.getmtime,
    )
    print(f"📂 Latest report: {latest_report_dir}")
    if open_report:
        c.run(f"allure open {latest_report_dir}", pty=True)


@task
def lint(c):
    """Run linting checks (flake8, black --check)"""
    print("🧹 Running lint checks...")
    c.run("flake8 .", pty=True)
    c.run("black --check .", pty=True)


@task
def clean(c):
    """Clean results and report directories"""
    for path, name in [(RESULTS_DIR, "results"), (REPORTS_DIR, "reports")]:
        if os.path.exists(path):
            shutil.rmtree(path)
            print(f"🗑️  Deleted {name} directory: {path}")
        else:
            print(f"⚠️  No {name} directory found")
