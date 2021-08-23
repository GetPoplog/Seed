#!/usr/bin/python3
from textwrap import dedent
from common import run_pop11_program

class TestPop11:
    def test_hello_world(self):
        assert run_pop11_program("'hello world' =>") == "** hello world"

    def test_nfib(self):
        nfib_src = dedent("""
        define nfib( n ); lvars n;
            if n <= 1 then
                1
            else
                nfib( n - 1) + nfib( n - 2 ) + 1
            endif
        enddefine;

        nfib( 15 ) =>
        """)
        assert run_pop11_program(nfib_src) == "** 1973"
