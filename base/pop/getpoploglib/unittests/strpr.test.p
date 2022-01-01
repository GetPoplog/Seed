compile_mode :pop11 +strict;

section;

define :unittest strpr_test ;
    assert strpr(#| |#) = '';;
    assert strpr(#| 'a', 'ab', 'abc' |#) = 'aababc';
enddefine;

endsection;