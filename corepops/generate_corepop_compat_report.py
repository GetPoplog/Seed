"""
Generate a markdown report of which corepops are compatible with which distributions.
"""
import subprocess
import functools
import docker
from typing import Iterable, NamedTuple, List
from pathlib import Path
from concurrent import futures
import os

HERE = Path(__file__).absolute().parent
DOCKER_CLIENT = docker.from_env()
OS_NAME = subprocess.check_output(["uname", "-s"]).decode("utf-8").lower().strip()
ARCH = subprocess.check_output(["uname", "-m"]).decode("utf-8").strip()

# All paths are done relative to the same directory this script is in.
os.chdir(HERE)

CONTAINERS = [
    # (container_name, tag)
    # equivalent to running: `docker run container_name:tag ...`
    ("ubuntu", "21.04"),
    ("ubuntu", "20.04"),
    ("ubuntu", "18.04"),
    ("ubuntu", "16.04"),
    ("archlinux", "latest"),
    ("debian", "unstable-slim"),
    ("debian", "testing-slim"),
    ("debian", "stable-slim"),
    ("debian", "oldstable-slim"),
    ("debian", "oldoldstable"),
    ("fedora", "34"),
    ("fedora", "33"),
    ("fedora", "32"),
    ("centos", "8"),
    ("centos", "7"),
]


class DistroTestResult(NamedTuple):
    image: str
    tag: str
    corepop: Path
    exit_code: int
    logs: str
    passed: bool


def main() -> None:
    corepops: List[Path] = list_available_corepops()
    configs = [
        (container, tag, corepop)
        for corepop in corepops
        for container, tag in CONTAINERS
    ]
    with futures.ThreadPoolExecutor(max_workers=20) as executor:
        results = executor.map(lambda args: run_corepop_in_container(*args), configs)
    table = generate_markdown_results_table(results)
    print(table)


def list_available_corepops() -> List[Path]:
    return sorted(
        [p for p in (Path(OS_NAME) / ARCH).iterdir() if p.name.endswith(".corepop")]
    )


def run_corepop_in_container(image: str, tag: str, corepop: Path) -> DistroTestResult:
    container = DOCKER_CLIENT.containers.run(
        image=f"{image}:{tag}",
        command=f"/bin/bash -c '/corepops/{corepop} \":sysexit()\"'",
        security_opt=["seccomp=unconfined"],
        volumes={str(Path().absolute()): {"bind": "/corepops", "mode": "ro"}},
        detach=True,
    )
    exit_code = container.wait()["StatusCode"]
    logs = container.logs(stdout=True, stderr=True).decode("utf-8")
    passed = len(logs.strip()) == 0
    return DistroTestResult(
        image=image,
        tag=tag,
        corepop=corepop,
        exit_code=exit_code,
        logs=logs,
        passed=passed,
    )


def generate_markdown_results_table(results: Iterable[DistroTestResult]) -> str:
    report = """\
| Corepop | Distribution | Version | Pass | Exit code | Logs |
| ------- | ------------ | ------- | ---- | --------- | ---- |
"""
    for result in results:
        pass_str = ":heavy_check_mark:" if result.passed else ":x:"
        if len(result.logs.strip()) == 0:
            logs_str = ""
        else:
            logs_line = result.logs.replace("\n", "<br>")
            logs_str = (
                f"<details><summary>details</summary><pre>{logs_line}</pre></details>"
            )
        report += (
            f"| {result.corepop} | {result.image} | {result.tag} "
            + f"| {pass_str} | {result.exit_code} | {logs_str} |\n"
        )

    return report



if __name__ == "__main__":
    main()
