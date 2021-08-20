import re
import tempfile
from common import run_poplog_commander


class TestCommands:
    def test_pop11(self):
        assert run_poplog_commander("pop11 :1 + 2=>") == "** 3"

    def test_clisp(self):
        assert run_poplog_commander("clisp :(+ 1 2) ") == "3"

    def test_ml(self):
        assert run_poplog_commander("pml :print(1+2)") == "3"

    def test_prolog(self):
        assert run_poplog_commander("prolog :3 = 3.") == "yes"

    def test_exec(self):
        assert run_poplog_commander("exec echo hello") == "hello"

    def test_shell(self):
        with tempfile.NamedTemporaryFile(suffix='.sh') as f:
            f.write("#!/bin/bash\necho hello\n".encode('utf-8'))
            f.flush()
            assert run_poplog_commander(f"shell {f.name}", extra_env={'SHELL': '/bin/bash'}) == "hello"

    def test_pop11_is_default(self):
        assert run_poplog_commander(":1 + 2=>") == "** 3"


class TestMiscFlags:
    def test_version_flag(self):
        assert re.match(r"Running base Poplog system \d+\.\d+", run_poplog_commander("--version"))

    def test_help_flags(self):
        help_msg = run_poplog_commander("--help")
        assert help_msg.startswith("Usage:")
        assert "UTILITY ACTIONS" in help_msg  # check that one of the section headings is present


class TestVariables:
    def test_setting_variables_in_shell_environment(self):
        assert run_poplog_commander("HELLO=hi exec sh -c 'echo $HELLO'") == "hi"

    def test_conflicting_environment_variable_are_overwritten_in_pop11_environment_in_run_mode(self):
        assert run_poplog_commander(
            ["--run", "pop11", ":systranslate('popcom')=>"],
            extra_env={"popcom": "/nosuchfile"},
        ).endswith("poplog/V16/pop/com")

    def test_conflicting_environment_variables_are_not_overwritten_in_pop11_environment_in_dev_mode(self):
        assert run_poplog_commander(
            ["pop11", ":maplist([%'popcom', 'FOO'%], systranslate)=>"],
            extra_env={"popcom": "/nosuchfile", "FOO": "BAR"},
        ) == "** [/nosuchfile BAR]"

    def test_non_conflicting_environment_variables_are_visible_in_pop11_environment_in_run_mode(self):
        assert run_poplog_commander(
            ["--run", "pop11", ":systranslate('FOO')=>"],
            extra_env={"FOO": "BAR"}
        ).endswith("BAR")

    def test_non_conflicting_environment_variables_are_visible_in_pop11_environment_in_dev_mode(self):
        assert run_poplog_commander(
            ["pop11", ":systranslate('FOO')=>"],
            extra_env={"FOO": "BAR"}
        ).endswith("BAR")

    def test_conflicting_cli_variables_are_not_overwritten_in_pop11_environment_in_run_mode(self):
        # In run mode, a variable definition specified within the CLI args should be honoured.
        assert run_poplog_commander(
                ["--run", "popcom=/nosuchfile", "pop11", ":systranslate('popcom')=>"]
        ) == "** /nosuchfile"

    def test_conflicting_cli_variables_are_not_overwritten_in_pop11_environment_in_dev_mode(self):
        # In run mode, a variable definition specified within the CLI args should be honoured.
        assert run_poplog_commander(
                ["popcom=/nosuchfile", "pop11", ":systranslate('popcom')=>"]
        ) == "** /nosuchfile"

    def test_non_conflicting_cli_variables_are_visible_in_pop11_environment_in_run_mode(self):
        assert run_poplog_commander(
            ["--run", "FOO=bar", "pop11", ":systranslate('FOO')=>"],
        ) == "** bar"

    def test_non_conflicting_cli_variables_are_visible_in_pop11_environment_in_dev_mode(self):
        assert run_poplog_commander(
            ["FOO=bar", "pop11", ":systranslate('FOO')=>"],
        ) == "** bar"
