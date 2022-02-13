compile_mode :pop11 +strict;

#_TERMIN_IF DEF pdorigin

section;

lconstant procedure pdorigin_table =
    newanyproperty(
        [], 8, 1, 8,
        false, false, "tmpval",
        conspair( false, false ),
        false
    );

define global constant procedure pdorigin( procedure p );
    pdorigin_table( p ).destpair
enddefine;

define updaterof pdorigin( file, linenum, procedure p );
    conspair( file, linenum ) -> pdorigin_table( p )
enddefine;

endsection;
