compile_mode :pop11 +strict;

section;

uses dict

define global constant procedure partapply_dict( procedure p, dict ) -> c;
    consclosure( dict.destdict_values, p ) -> c;
    dict.destdict_keys -> c.frozval_names;
enddefine;

endsection;
