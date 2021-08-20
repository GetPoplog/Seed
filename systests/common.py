import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import List, Union


POPLOG_BINARY_PATH = shutil.which("poplog")
HERE = Path(__file__).absolute().parent


def run_poplog_commander(args: Union[str, List[str]], extra_env=None) -> str:
    if extra_env is None:
        extra_env = dict()
    env = {**os.environ, **extra_env}
    if isinstance(args, str):
        args = shlex.split(args)
    completed_process = subprocess.run(
        [POPLOG_BINARY_PATH] + args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env
    )
    assert completed_process.returncode == 0
    return completed_process.stdout.decode("utf-8").strip()


def run_pop11_program(src: str) -> str:
    with tempfile.NamedTemporaryFile(suffix=".p") as src_file:
        src_file.write(src.encode("utf-8"))
        src_file.flush()
        return run_poplog_commander(["pop11", src_file.name])
