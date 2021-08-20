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
    stderr = completed_process.stderr.decode("utf-8")
    stdout = completed_process.stdout.decode("utf-8")
    err_msg = (
        f"Process failed with exit-code {completed_process.returncode}" +
        f"\nSTDOUT:\n\n{stdout}\nSTDERR:\n\n{stderr}\n"
    )
    assert completed_process.returncode == 0, err_msg
    return stdout.strip()


def run_pop11_program(src: str) -> str:
    with tempfile.NamedTemporaryFile(suffix=".p") as src_file:
        src_file.write(src.encode("utf-8"))
        src_file.flush()
        return run_poplog_commander(["pop11", src_file.name])
