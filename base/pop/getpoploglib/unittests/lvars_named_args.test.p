
/*

TODO: Turn these examples into some form of unittests.

define evil1();
    lvars_named_args -&- xxx;
enddefine;

define foo() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no";
    [ ^x ^y ^a ^b ] =>
enddefine;

define bar() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no", mmm;
    [ ^x ^y ^a ^b ^mmm ] =>
enddefine;

define gort() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no", mmm, nnn;
    [ ^x ^y ^a ^b ^mmm ^nnn ] =>
enddefine;

define evil2();
    lvars_named_args -&- yyy;
enddefine;


foo( "x", "y" );
foo( "x", "y" -&- a = "AAA" );
foo( "x", "y" -&- b = "BBB" );
foo( "x", "y" -&- b = "BBB", a = "AAA" );

bar( "x", "y" -&- mmm = "MMM" );
bar( "x", "y" -&- a = "AAA", mmm = "MMM" );
bar( "x", "y" -&- b = "BBB",  mmm = "MMM" );

gort( "x", "y" -&- nnn = "NNN", mmm = "MMM" );
gort( "x", "y" -&- );

*/
