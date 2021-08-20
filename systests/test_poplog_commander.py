from common import run_poplog_commander


class TestInterpreters:
    def test_pop11(self):
        assert run_poplog_commander("pop11 :1 + 2=>") == "** 3"

    def test_clisp(self):
        assert run_poplog_commander("clisp :(+ 1 2) ") == "3"

    def test_ml(self):
        assert run_poplog_commander("pml :print(1+2)") == "3"

    def test_prolog(self):
        assert run_poplog_commander("prolog :3 = 3.") == "yes"


class TestExec:
    def test_echo(self):
        assert run_poplog_commander("exec echo hello") == "hello"

    def test_setting_variables_in_shell_environment(self):
        assert run_poplog_commander("HELLO=hi exec sh -c 'echo $HELLO'") == "hi"

    def test_environment_variables_are_overwritten_in_pop11_environment_in_run_mode(self):
        assert run_poplog_commander(
            ["--run", "pop11", ":systranslate('popcom')=>"],
            extra_env={"popcom": "/nosuchfile"},
        ).endswith("poplog/V16/pop/com")

    def test_cli_variables_are_not_overwritten_in_pop11_environment_in_run_mode(self):
        # In run mode, a variable definition specified within the CLI args should be honoured.
        assert run_poplog_commander(
                ["--run", "popcom=/nosuchfile", "pop11", ":systranslate('popcom')=>"]
        ) == "** /nosuchfile"

    def test_cli_variables_are_visible_in_pop11_environment_in_dev_mode(self):
        assert run_poplog_commander(
            ["FOO=bar", "pop11", ":systranslate('FOO')=>"],
        ) == "** bar"


    def test_non_overwritten_environment_variables_are_visible_in_pop11_environment_in_run_mode(self):
        assert run_poplog_commander(
            ["--run", "pop11", ":systranslate('FOO')=>"],
            extra_env={"FOO": "BAR"}
        ).endswith("BAR")

    def test_environment_variables_are_not_overwritten_in_pop11_environment_in_dev_mode(self):
        assert run_poplog_commander(
                ["pop11", ":maplist([%'popcom', 'FOO'%], systranslate)=>"],
                extra_env={"popcom": "/nosuchfile", "FOO": "BAR"},
        ) == "** [/nosuchfile BAR]"


