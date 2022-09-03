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

    def test_updateof_testbit(self):
        assert (
            run_pop11_program( "true -> testbit( 30693733391817156297112049438, 95 ) =>" ) == 
            f"** {(1 << 95) | 30693733391817156297112049438}"
        )
        assert (
            run_pop11_program("true -> testbit( 5110700429819126684, 63 ) =>") == 
            f"** {(1 << 63) | 5110700429819126684}"
        )
        assert (
            run_pop11_program("true -> testbit( 2309579545893710632583768152453332180599682146927526616900307024944, 223 ) =>") == 
            f"** {(1 << 223) | 2309579545893710632583768152453332180599682146927526616900307024944}"
        )

    def test_bigint_rem(self):
        cmd = """2357947691 rem 100000000000000006579 =>"""
        assert (
            run_pop11_program(cmd) == 
            f"** {2357947691 % 100000000000000006579}"
        )

    def test_gcd(self):
        cmd = (
            """
            vars a = -1169201309864722334558986458047313198845068836864;
            vars b = 531266229322835086541;
            gcd_n(a, b, 2), a // b =>
            """
        )
        assert (
            run_pop11_program(cmd) == 
            f"** 1 -446001278937690371636 -2200782292062898266479046908"
        )

    def test_left_shift(self):
        assert (
            run_pop11_program("-1490116119384765625 << 2 =>") == 
            f"** {-1490116119384765625 << 2}"
        )
