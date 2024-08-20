compile_mode :pop11 +strict;

uses namedtuple

section $-namedtuple => destnamedtuple_values;

define global constant procedure destnamedtuple_values( namedtuple );
    namedtuple.namedtuple_values.destvector
enddefine;

endsection;
