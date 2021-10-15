compile_mode :pop11 +strict;

section $-unittest =>
    define_testsuite        ;;; used for defining test collections
    define_unittest         ;;; used for defining unit tests
    assert                  ;;; used for defining unit tests
    expect_mishap           ;;; used for defining unit tests
    with_data               ;;; used for defining unit tests with scenario data
    register_unittest       ;;; exported because of code-planting
;


constant unittest_suffix = '.test.p';

;;; --- expecting mishaps ---

vars mishap_happened = false;

vars _expect_mishap = false;

define global active:1 expect_mishap();
    _expect_mishap;
enddefine;

define updaterof active:1 expect_mishap( saved );
    saved -> _expect_mishap;
    if not(saved) and not( mishap_happened ) do
        mishap( 'Expected mishap was skipped', [] )
    endif;
enddefine;

;;; --- test discovery and execution ---

vars unittest_passes = undef;           ;;; Part of test-execution.
vars unittest_failures = undef;         ;;; Part of test-execution.
vars current_unittest = undef;          ;;; Part of test-execution.

;;; Part of test-discovery, although may be re-invoked during execution.
;;; At top-level do nothing. This will be dlocalised during test-discovery.
define vars register_unittest( u );
enddefine;

;;; Part of test-execution.
;;; This is defensive - we only want to run unit tests inside an appropriate
;;; dynamic context.
define vars run_unittest( p );
    mishap( 'Trying to trace unit tests with context (this should never happen)', [] )
enddefine;

defclass failureinfo {
    failureinfo_unittest,
    failureinfo_message,
    failureinfo_idstring,
    failureinfo_argv
};

;;; Part of test-execution.
;;; This will only be invoked at top-level and hence outside of a test
;;; context, so it is OK for it to simply mishap.
define vars fail_unittest( info );
    mishap( 'Unittest failed', [] )
enddefine;

define fail_unittest_during_execution( info );
    unittest_failures( info );
    exitfrom( run_unittest )
enddefine;

;;; This is the normal way to run a unit test & we will dlocalise run_unittest
;;; to its value.
define run_unittest_during_execution( p );

    define lconstant is_expected_mishap( mess, idstring, severity, args );
        if isstartstring( 'unittest-assert:', idstring ) then
            false
        elseif expect_mishap == true then
            true
        elseif expect_mishap.isstring then
            idstring = expect_mishap or mess = expect_mishap
        elseif expect_mishap.isregexp then
            expect_mishap( 1, idstring, false, false ) or expect_mishap( 1, mess, false, false )
        elseif expect_mishap.isprocedure and not( expect_mishap.isregexp ) then
            expect_mishap( mess, idstring, severity, args )
        else
            false
        endif;
    enddefine;

    define dlocal pop_exception_final( N, mess, idstring, severity );
        returnunless( severity == `E` or severity == `R` )( false );
        true -> mishap_happened;
        lvars args = conslist( N );
        lvars is_expected = is_expected_mishap( mess, idstring, severity, args );
        if is_expected then
            exitto( run_unittest );
        else
            chain( consfailureinfo( current_unittest, mess, idstring, args ), fail_unittest )
        endif;
    enddefine;

    dlocal current_unittest = p;
    dlocal mishap_happened = false;
    p();
    unittest_passes( p );
enddefine;

define discover_unittests( p );
    dlocal register_unittest = new_list_builder();
    erasenum(#| p() |#);
    return( register_unittest( termin ) )
enddefine;

define run_all_unittests( unittest_list );
    dlocal unittest_passes = new_list_builder();
    dlocal unittest_failures = new_list_builder();
    [% applist( unittest_list, run_unittest ) %] -> _; ;;; defensive.
    ( unittest_passes( termin ), unittest_failures( termin ) )
enddefine;


;;; --- Discovery ---

;;; This is a class to collect the results from discovery - especially inside VED.
defclass discovered {
    discovered_unittests,
    discovered_files_cache
};

define newdiscovered( unittests );
    consdiscovered( unittests, false )
enddefine;

define discovered_files( d );
    if d.discovered_files_cache then
        d.discovered_files_cache
    else
        lvars t = (
            newanyproperty(
                [], 8, 1, 8,
                syshash, nonop =, "perm",
                false, false
            )
        );
        lvars u;
        for u in d.discovered_unittests do
            lvars ( parent, linenum ) = pdorigin( u );
            if parent.isstring do
                true -> t( parent )
            endif
        endfor;
        nc_listsort( [% fast_appproperty( t, erase ) %], alphabefore ) ->> d.discovered_files_cache;
    endif
enddefine;


;;; --- Syntax ---

vars procedure unittest_sysVARS = sysVARS;

define read_declaration( defdec ) -> ( pdrname, props, is_global, declarator );
    lvars attributes = (
        [%
            repeat
                lvars item = nextreaditem();
                if item == termin then
                    mishap( 'Unexpected end of input in unittest definition', [] )
                endif;
                lvars id = identprops( item );
                quitunless( id.isword );
                quitunless( isstartstring( "syntax", id ) );
                quitif( item == ";" or item == "(" );
                readitem()
            endrepeat
        %]
    );
    readitem() -> pdrname;

    false -> is_global;
    defdec -> declarator;

    lvars a;
    for a in attributes do
        if a == "global" then
            true -> is_global
        elseif a == "lconstant" then
            sysLCONSTANT -> declarator;
        elseif a == "lvars" then
            sysLVARS -> declarator;
        elseif a == "constant" then
            sysCONSTANT -> declarator;
        elseif a == "vars" then
            sysVARS -> declarator;
        else
            mishap( 'Unexpected syntax word', [^a] )
        endif
    endfor;

    if pdrname == ";" or item == "(" then
        pdrname :: proglist -> proglist;
        sysNEW_LVAR() -> pdrname;
        false -> is_global;
        procedure( w, n ); endprocedure -> declarator;
        "anonymous_unittest" -> props;
    else
        pdrname -> props
    endif;
enddefine;

define core_define_unittest();
    lvars ( pdrname, props, is_global, declarator ) = read_declaration( unittest_sysVARS );

    lvars captured_popfilename = popfilename or vedpathname;
    lvars captured_poplinenum = poplinenum;

    declarator( pdrname, 0 );
    if is_global then sysGLOBAL( pdrname, is_global ) endif;
    sysPROCEDURE( props, 0 );
    dlocal unittest_sysVARS = sysLVARS;
    sysLOCAL( "ident $-unittest$-mishap_happened" );
    ;;; Main body.
    sysCALLQ( pop11_comp_procedure( "enddefine", false, pdrname and pdrname >< "_body" or "unittest_body" ) );
    sysPASSIGN( sysENDPROCEDURE(), pdrname );

    sysPUSHQ( captured_popfilename );
    sysPUSHQ( captured_poplinenum );
    sysPUSH( pdrname );
    sysUCALL( "pdorigin" );

    return( pdrname );
enddefine;

define :define_form global unittest;
    lvars pdrname = core_define_unittest();
    sysPUSH( pdrname );
    sysCALL( "register_unittest" );
enddefine;

;;; with_data
;;;     [0 1]
;;;     [1 2]
;;; define :unittest foo( x, y );
;;; enddefine;
define syntax with_data;

    define register_closures( data, pdr );
        lvars d;
        for d in data do
            register_unittest( pdr(% d.explode %) )
        endfor
    enddefine;

    dlocal pop_new_lvar_list;
    lvars data = sysNEW_LVAR();
    sysPUSH( "popstackmark" );
    until pop11_try_nextitem( "define" ) do
        pop11_comp_expr();
    enduntil;
    pop11_need_nextreaditem( ":" ) -> _;
    pop11_need_nextreaditem( "unittest" ) -> _;
    sysCALL( "sysconslist" );
    sysPOP( data );
    lvars pdrname = core_define_unittest();
    sysPUSH( data );
    sysPUSH( pdrname );
    sysCALLQ( register_closures );
enddefine;


;;; --- Syntax: testsuite

define :define_form global testsuite;
    lvars ( pdrname, props, is_global, declarator ) = read_declaration( unittest_sysVARS );
    pop11_need_nextreaditem( ";" ) -> _;
    declarator( pdrname, 0 );
    if is_global then sysGLOBAL( pdrname, is_global ) endif;
    sysPROCEDURE( props, 0 );
    dlocal unittest_sysVARS = sysLVARS;
    pop11_comp_stmnt_seq_to( "enddefine" ) -> _;
    sysPASSIGN( sysENDPROCEDURE(), pdrname );
    sysCALL( pdrname );
enddefine;


;;; --- Syntax: assert ---

;;; Return a copy of the expanded portion of a partially expanded
;;; dynamic list without causing any further expansion.
define lconstant only_expanded( L );
    [%
        while L.ispair and not( L.fast_back.isprocedure ) do
            L.fast_destpair -> L
        endwhile;
    %]
enddefine;

;;; -peek_expr_to- does not consume any input nor plant any code but expands -proglist-
;;; by exactly one Pop-11 expression and returns the expanded portion.
define lconstant peek_expr_to( closing_keyword );
    dlocal pop_syntax_only = true;
    dlocal proglist_state;
    lvars old_proglist = proglist;
    pop11_comp_expr_to( closing_keyword ) -> _;
    old_proglist.only_expanded;
enddefine;

define global syntax assert();

    define lconstant check_assertion( N, filename, linenum, expr );
        if N == 0 then
            mishap( 0, 'No results from assertion', 'unittest-assert:stack-empty' )
        elseif N > 1 then
            mishap( N, 'Too many results from assertion', 'unittest-assert:stack-many' )
        else
            lvars result = ();
            unless result do
                mishap( #| filename, linenum, expr |#, 'Assertion failed', 'unittest-assert:unittest-fail' )
            endunless
        endif
    enddefine;

    dlocal pop_new_lvar_list;
    lvars t = sysNEW_LVAR();
    sysCALL( "stacklength" );
    sysPOP( t );
    lvars expr = peek_expr_to( ";" );
    pop11_comp_expr();
    sysCALL( "stacklength" );
    sysPUSH( t );
    sysCALL( "fi_-" );
    sysPUSHQ( popfilename );
    sysPUSHQ( poplinenum );
    sysPUSHQ( expr );
    sysCALLQ( check_assertion );
enddefine;


;;; --- Common reporting ---

define r_pdprops( u );
    while u.isclosure and not( u.pdprops ) do
        u.pdpart -> u
    endwhile;
    lvars props = u.pdprops;
    while props.islist and not( null( props ) ) do
        props.hd -> props
    endwhile;
    props;
enddefine;

define pr_show_failures( passes, failures );
    dlocal poplinewidth = false;
    dlocal pop_pr_quotes = false;
    nprintf( 'Test results at: ' <> sysdaytime() );
    nl(1);

    lvars i, n;
    for i, n in failures, list_from(1) do
        lvars ( u, msg, idstring, args ) = i.destfailureinfo;
        if idstring = 'unittest-assert:unittest-fail' then
            lvars name = u.r_pdprops;
            nprintf( '%p.\tFailed    : %p', [^n ^name] );
            if u.isclosure then
                nprintf( '\tData      : %p', [[% u.explode %]])
            endif;
            lvars (filename, linenumber, assert_expr, _n) = args.destlist;
            if hasstartstring( filename, current_directory ) then
                allbutfirst( datalength(current_directory) + 1, filename ) -> filename;
            endif;
            printf( '\tExpression: ' );
            applist( [assert ^^assert_expr], procedure(); dlocal pop_pr_quotes = true; spr() endprocedure );
            nl(1);
            nprintf( '\tLine num  : %p', [ ^linenumber ] );
            nprintf( '\tFile name : %p', [ ^filename ] );
        else
            lvars name = u.r_pdprops;
            lvars ( parent, linenum ) = u.pdorigin;
            nprintf( '%p.\tUnit test : %p', [^n ^name] );
            nprintf( '\tMessage   : %p', [ ^msg ] );
            unless args.null do
                npr( '\tInvolving : ' );
                lvars a;
                for a in args do
                    nprintf( '\t *\t%p', [^a] )
                endfor;
            endunless;
            if parent then
                if linenum then
                    nprintf( '\tLine num  : %p', [ ^linenum ] );
                endif;
                if parent.isstring then
                    if hasstartstring( parent, current_directory ) then
                        allbutfirst( datalength(current_directory) + 1, parent ) -> parent;
                    endif;
                    nprintf( '\tFrom      : %p', [ ^parent ] );
                endif;
            endif;
        endif;
        nl( 1 );
    endfor;
enddefine;

define pr_show_discovered( d );
    dlocal poplinewidth = false;
    dlocal pop_pr_quotes = false;
    nprintf( 'Test discovery at: ' <> sysdaytime() );
    nl( 1 );

    nprintf( 'Files compiled during discovery (total of %p)', [% d.discovered_files.length %] );
    lvars file, n;
    for file, n in d.discovered_files, list_from(1) do
        nprintf( '%p. %p', [% n, file %] );
    endfor;
    nl(1);

    nprintf( 'Unittests discovered (total of %p)', [% d.discovered_unittests.length %] );
    lvars u, n;
    for u, n in d.discovered_unittests, list_from(1) do
        nprintf( '%p. %p', [% n, u %] );
    endfor;
    nl(1);

enddefine;

endsection;
