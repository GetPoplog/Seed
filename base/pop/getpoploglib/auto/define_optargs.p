compile_mode :pop11 +strict;

section $-gospl$-named_args =>
    define_optargs
    ;



/* NOTES TO MYSELF

1.  Need to implement default value syntax via closures-with-names.
2.  Need to adapt the lvars_named_syntax to terminate on a ")" and
3.  to support "==" for default values.
4.  Adapt the get_args so that it pops named arguments with default
    values off the stack.
5.  The pop order should be the left-to-right order of arguments,
    so the order of the frozvals will be the reverse to what the
    naive programmer might expect (but they should be accessing by
    name anyway).

*/

define :define_form optargs;
    mishap( 'TO BE IMPLEMENTED', [] )
enddefine;


endsection;
