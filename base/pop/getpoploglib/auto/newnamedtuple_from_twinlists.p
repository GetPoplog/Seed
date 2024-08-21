compile_mode :pop11 +strict;

section $-namedtuple => newnamedtuple_from_twinlists;

uses namedtuple

define global constant procedure newnamedtuple_from_twinlists( keys_list, values_list );
    fast_make_namedtuple_from_unsorted(
         keys_list.destlist,
         values_list.destlist
    )
enddefine;

endsection;
