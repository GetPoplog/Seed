compile_mode :pop11 +strict;

section;

define lconstant compile_dict_to( end_word ) with_props 'dollar_{';
    sysPUSHQ( popstackmark );
    until pop11_try_nextreaditem( end_word ) do
        while pop11_try_nextreaditem( "," ) do endwhile;
        lvars k = readitem();
        unless k.isword do
            mishap( 'Expected word as namedtuple key', [^k] )
        endunless;
        pop11_need_nextreaditem( "=" ) -> _;
        sysPUSHQ( popstackmark );
        sysPUSHQ( k );
        pop11_comp_N( pop11_comp_expr, 1 );
        sysCALLQ( sysconslist );
    enduntil;
    sysCALLQ( sysconslist );
    sysCALL( "newdict_from_assoclist" );
enddefine;

;;;
;;; Pop-11 really does not like the identifier dollar_{ so we need to force
;;; the assignment with some low-level code.
;;;
ident_declare( "'dollar_{'", "syntax", 0 );
procedure(word) with_props 'dollar_{';
    compile_dict_to( "}" )
endprocedure -> idval( identof( "'dollar_{'" ) );

endsection;
