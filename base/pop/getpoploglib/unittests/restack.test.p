compile_mode :pop11 +strict;

section;

define :unittest do_nothing();
    lvars zero = stacklength();
    restack -> ;
    assert stacklength() == zero;
enddefine;

define :unittest swap();
    ( "foo", "bar" );
    restack x y -> y x;
    lvars z = () <> ();
    assert "barfoo" == z;
enddefine;

define :unittest duplicate();
    ( "foo", "bar" );
    restack x y -> y y;
    lvars z = () <> ();
    assert "barbar" == z;
enddefine;

define :unittest shrink_stack();
    lvars n = stacklength();
    ( "foo", "bar" );
    restack x y -> y;
    lvars z = ();
    assert "bar" == z;
    assert stacklength() == n;
enddefine;

define :unittest grow_stack();
    lvars n = stacklength();
    ( "foo", "bar" );
    restack x y -> x y x y;
    lvars z = () <> () <> () <> ();
    assert "foobarfoobar" == z;
    assert stacklength() == n;
enddefine;

endsection;
