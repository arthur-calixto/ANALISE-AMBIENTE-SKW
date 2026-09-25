"""Testa o fluxo de deploy sem acessar Docker ou produção."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/deploy.sh"
MOCK = r"""#!/usr/bin/env python3
import os, sys
from pathlib import Path
args = sys.argv[1:]
with open(os.environ["CALLS"], "a") as log:
    log.write(os.environ["APP_IMAGE"] + " " + " ".join(args) + "\n")
mode = os.environ["MODE"]
if args[0] == "ps" and mode != "first_failure":
    print("analise-ambiente")
elif args[0] == "inspect":
    if ".Image" in args[2]:
        print("sha256:" + "b" * 64)
    else:
        print("wrong" if mode == "wrong_project" else "modelo")
elif args[0] == "compose" and "pull" in args and mode == "pull_failure":
    sys.exit(1)
elif args[0] == "compose" and "up" in args:
    if mode == "rollback_failure":
        sys.exit(1)
    if mode in ("health_failure", "first_failure") and os.environ["APP_IMAGE"].startswith("ghcr.io/"):
        sys.exit(1)
"""

class DeployTests(unittest.TestCase):
    def run_deploy(self, mode, image=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docker").write_text(MOCK)
            (root / "docker").chmod(0o755)
            (root / "prod.env").touch()
            (root / "data").mkdir()
            env = dict(os.environ, PATH=str(root) + ":" + os.environ["PATH"],
                       APP_IMAGE=image or "ghcr.io/example/app@sha256:" + "a" * 64,
                       PROD_ENV_FILE=str(root / "prod.env"),
                       PROD_DATA_DIR=str(root / "data"), COMPOSE_PROJECT_NAME="modelo",
                       MODE=mode, CALLS=str(root / "calls"))
            env.pop("GITHUB_STEP_SUMMARY", None)
            result = subprocess.run(["bash", str(SCRIPT)], env=env, text=True, capture_output=True)
            calls = (root / "calls").read_text() if (root / "calls").exists() else ""
            return result, calls

    def test_success_pulls_before_up(self):
        result, calls = self.run_deploy("success")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(calls.index(" pull"), calls.index(" up"))
        self.assertEqual(calls.count(" up "), 1)

    def test_download_failure_keeps_current_container(self):
        result, calls = self.run_deploy("pull_failure")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(" up ", calls)

    def test_unhealthy_update_restores_previous_image(self):
        result, calls = self.run_deploy("health_failure")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls.count(" up "), 2)
        self.assertIn("sha256:" + "b" * 64 + " compose", calls)
        self.assertIn("--pull never", calls)

    def test_wrong_project_stops_before_download(self):
        result, calls = self.run_deploy("wrong_project")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(" pull", calls)
        self.assertNotIn(" up ", calls)

    def test_first_deploy_failure_has_no_rollback(self):
        result, calls = self.run_deploy("first_failure")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls.count(" up "), 1)

    def test_rollback_failure_is_reported(self):
        result, calls = self.run_deploy("rollback_failure")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Rollback falhou", result.stdout)

    def test_mutable_image_is_rejected(self):
        result, calls = self.run_deploy("success", "ghcr.io/example/app:latest")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, "")

if __name__ == "__main__":
    unittest.main()
