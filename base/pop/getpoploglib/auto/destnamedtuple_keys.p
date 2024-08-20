compile_mode :pop11 +strict;

uses namedtuple

section $-namedtuple => destnamedtuple_keys;

define global constant procedure destnamedtuple_keys( namedtuple );
    namedtuple.namedtuple_keys.destvector
enddefine;

endsection;
