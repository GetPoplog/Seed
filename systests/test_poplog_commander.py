import re
import subprocess
import tempfile
from pathlib import Path
from common import check_poplog_commander, run_poplog_commander
from typing import Optional
import pytest


LDD: Optional[str]
try:
    LDD = subprocess.check_output(["which", "ldd"]).strip().decode('utf-8')
except subprocess.CalledProcessError:
    LDD = None


class TestCommands:
    def test_pop11(self):
        assert check_poplog_commander("pop11 :1 + 2=>") == "** 3"

    def test_clisp(self):
        assert check_poplog_commander("clisp :(+ 1 2) ") == "3"

    def test_ml(self):
        assert check_poplog_commander("pml :print(1+2)") == "3"

    def test_prolog(self):
        assert check_poplog_commander("prolog :3 = 3.") == "yes"

    def test_exec(self):
        assert check_poplog_commander("exec echo hello") == "hello"

    def test_shell(self):
        with tempfile.NamedTemporaryFile(suffix='.sh') as f:
            f.write("#!/bin/bash\necho hello\n".encode('utf-8'))
            f.flush()
            assert check_poplog_commander(f"shell {f.name}", extra_env={'SHELL': '/bin/bash'}) == "hello"

    def test_pop11_is_default(self):
        assert check_poplog_commander(":1 + 2=>") == "** 3"


class TestMiscFlags:
    def test_version_flag(self):
        assert re.match(r"Running base Poplog system \d+\.\d+", check_poplog_commander("--version"))

    def test_help_flags(self):
        help_msg = check_poplog_commander("--help")
        assert help_msg.startswith("Usage:")
        assert "UTILITY ACTIONS" in help_msg  # check that one of the section headings is present


class TestVariables:
    def test_setting_variables_in_shell_environment(self):
        assert check_poplog_commander("HELLO=hi exec sh -c 'echo $HELLO'") == "hi"

    def test_conflicting_environment_variable_are_overwritten_in_pop11_environment_in_run_mode(self):
        assert check_poplog_commander(
            ["--run", "pop11", ":systranslate('popcom')=>"],
            extra_env={"popcom": "/nosuchfile"},
        ).endswith("poplog/V16/pop/com")

    def test_conflicting_environment_variables_are_not_overwritten_in_pop11_environment_in_dev_mode(self):
        assert check_poplog_commander(
            ["pop11", ":maplist([%'popcom', 'FOO'%], systranslate)=>"],
            extra_env={"popcom": "/nosuchfile", "FOO": "BAR"},
        ) == "** [/nosuchfile BAR]"

    def test_non_conflicting_environment_variables_are_visible_in_pop11_environment_in_run_mode(self):
        assert check_poplog_commander(
            ["--run", "pop11", ":systranslate('FOO')=>"],
            extra_env={"FOO": "BAR"}
        ).endswith("BAR")

    def test_non_conflicting_environment_variables_are_visible_in_pop11_environment_in_dev_mode(self):
        assert check_poplog_commander(
            ["pop11", ":systranslate('FOO')=>"],
            extra_env={"FOO": "BAR"}
        ).endswith("BAR")

    def test_conflicting_cli_variables_are_not_overwritten_in_pop11_environment_in_run_mode(self):
        # In run mode, a variable definition specified within the CLI args should be honoured.
        assert check_poplog_commander(
                ["--run", "popcom=/nosuchfile", "pop11", ":systranslate('popcom')=>"]
        ) == "** /nosuchfile"

    def test_conflicting_cli_variables_are_not_overwritten_in_pop11_environment_in_dev_mode(self):
        # In run mode, a variable definition specified within the CLI args should be honoured.
        assert check_poplog_commander(
                ["popcom=/nosuchfile", "pop11", ":systranslate('popcom')=>"]
        ) == "** /nosuchfile"

    def test_non_conflicting_cli_variables_are_visible_in_pop11_environment_in_run_mode(self):
        assert check_poplog_commander(
            ["--run", "FOO=bar", "pop11", ":systranslate('FOO')=>"],
        ) == "** bar"

    def test_non_conflicting_cli_variables_are_visible_in_pop11_environment_in_dev_mode(self):
        assert check_poplog_commander(
            ["FOO=bar", "pop11", ":systranslate('FOO')=>"],
        ) == "** bar"

    def test_error_message_on_invalid_var_spec(self):
        completed_process = run_poplog_commander(["FOO", "exec", "echo" "hello"])
        assert completed_process.returncode == 1
        # TODO: Add test of error message once
        # https://github.com/GetPoplog/Seed/issues/103 is resolved.

    def test_error_message_on_command(self):
        completed_process = run_poplog_commander(["asdf"])
        assert completed_process.returncode == 1
        # TODO: Add test of error message once
        # https://github.com/GetPoplog/Seed/issues/103 is resolved.


class TestBuilds:
    def test_nox_build_path(self):
        assert self.get_nox_popsys().name == "pop-nox"

    def test_motif_build_path(self):
        assert self.get_motif_popsys().name == "pop-xm"

    def test_xt_build_path(self):
        assert self.get_xt_popsys().name == "pop-xt"

    def test_default_build_is_motif(self):
        assert self.get_default_popsys().name == "pop-xm"

    def test_nox_build_has_no_xved_binary(self):
        assert len([p for p in self.get_nox_popsys().iterdir() if p.name == 'xved']) == 0

    @pytest.mark.skipif(LDD is None, reason="requires ldd to test")
    def test_motif_build_has_xved_linked_to_motif(self):
        xved = self.get_motif_popsys() / 'xved'
        ldd_output = subprocess.check_output([LDD, xved]).strip().decode('utf-8')
        assert 'libXm.so' in ldd_output

    @pytest.mark.skipif(LDD is None, reason="requires ldd to test")
    def test_xt_build_has_xved_not_linked_to_motif(self):
        xved = self.get_xt_popsys() / 'xved'
        ldd_output = subprocess.check_output([LDD, xved]).strip().decode('utf-8')
        assert 'libXm.so' not in ldd_output

    def get_default_popsys(self) -> Path:
        return Path(check_poplog_commander(["exec", "sh", "-c", "echo $popsys"]))

    def get_nox_popsys(self) -> Path:
        return Path(check_poplog_commander(["--no-gui", "exec", "sh", "-c", "echo $popsys"]))

    def get_xt_popsys(self) -> Path:
        return Path(check_poplog_commander(["--gui=xt", "exec", "sh", "-c", "echo $popsys"]))

    def get_motif_popsys(self) -> Path:
        return Path(check_poplog_commander(["--gui=motif", "exec", "sh", "-c", "echo $popsys"]))
