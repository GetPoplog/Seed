compile_mode :pop11 +strict;

section $-namedtuple => nullnamedtuple;

global constant nullnamedtuple = consnamedtuple( {}.dup );

endsection;
