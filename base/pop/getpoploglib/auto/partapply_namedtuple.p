compile_mode :pop11 +strict;

section;

uses namedtuple

define global constant procedure partapply_namedtuple( procedure p, namedtuple ) -> c;
    consclosure( p, namedtuple.destnamedtuple_values ) -> c;
    namedtuple.destnamedtuple_keys -> c.frozval_names;
enddefine;

endsection;
