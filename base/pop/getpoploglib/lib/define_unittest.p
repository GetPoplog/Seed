compile_mode :pop11 +strict;

section $-unittest =>
    define_unittest         ;;; used for defining unit tests
    assert                  ;;; used for defining unit tests
    expect_mishap           ;;; used for defining unit tests
    with_data               ;;; used for defining unit tests with scenario data
    register_unittest       ;;; exported because of code-planting
;

vars expect_mishap = false;     ;;; Part of test-execution.

vars pop_unittests = undef;     ;;; Part of test-discovery.
vars unittest_passes = undef;   ;;; Part of test-execution.
vars unittest_failures = undef; ;;; Part of test-execution.
vars current_unittest = undef;  ;;; Part of test-execution.

;;; Part of test-discovery, although may be re-invoked during execution.
;;; At top-level do nothing.
define vars register_unittest( u );
enddefine;

defclass context {
    context_parent,
    context_linenum
};

;;; This is a map from unit-tests, which are procedures, to the context in
;;; which they were defined.
constant procedure registration_table =
    newanyproperty(
        [], 8, 1, 8,
        false, false, "tmpval",
        false, false
    );

;;; Inside a test-context we record the notional parent. This is purely
;;; so we can present the test results inside a nice-looking classification tree.
define vars register_unittest_during_discovery( u );
    lvars index = popfilename or vedpathname;
    if index do
        conscontext( index, poplinenum ) -> registration_table( u );
    endif;
    pop_unittests( u );
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
        lvars args = conslist( N );
        lvars is_expected = is_expected_mishap( mess, idstring, severity, args );
        if is_expected then
            exitto( run_unittest );
        else
            chain( consfailureinfo( current_unittest, mess, idstring, args ), fail_unittest )
        endif;
    enddefine;

    dlocal current_unittest = p;
    p();
    if expect_mishap then
        lvars info = consfailureinfo( current_unittest, 'Required mishap skipped', '', [] );
        unittest_failures( p );
    else
        unittest_passes( p );
    endif
enddefine;

define discover_unittests( p );
    dlocal pop_unittests = new_list_builder();
    dlocal register_unittest = register_unittest_during_discovery;
    erasenum(#| p() |#);
    return( pop_unittests( termin ) )
enddefine;

define run_all_unittests( unittest_list );
    dlocal unittest_passes = new_list_builder();
    dlocal unittest_failures = new_list_builder();
    [% applist( unittest_list, run_unittest ) %] -> _; ;;; defensive.
    ( unittest_passes( termin ), unittest_failures( termin ) )
enddefine;

vars procedure unittest_sysVARS = sysVARS;

define read_declaration( defdec ) -> ( pdrname, is_global, declarator );
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
    endif;
enddefine;

define core_define_unittest();
    dlocal pop_new_lvar_list;

    define lconstant run_all( list_builder );
        applist( list_builder( termin ), run_unittest )
    enddefine;

    lvars ( pdrname, is_global, declarator ) = read_declaration( unittest_sysVARS );
    declarator( pdrname.isword and pdrname, 0 );
    if is_global then sysGLOBAL( pdrname, is_global ) endif;
    sysPROCEDURE( pdrname, 0 );

    ;;; Set up dynamic test discovery.
    lvars collector = sysNEW_LVAR();
    sysCALL( "new_list_builder" );
    sysPOP( collector );
    sysLOCAL( "register_unittest" );
    sysPUSH( collector );
    sysPOP( "register_unittest" );

    ;;; Main body.
    sysCALLQ( pop11_comp_procedure( "enddefine", false, pdrname and pdrname >< "_body" or "unittest_body" ) );

    ;;; Run any registered tests.
    sysPUSH( collector );
    sysCALLQ( run_all );

    sysPASSIGN( sysENDPROCEDURE(), pdrname );

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

constant unittest_suffix = '.test.p';

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
            lvars parent = context_parent( registration_table( u ) );
            if parent.isstring do
                true -> t( parent )
            endif
        endfor;
        nc_listsort( [% fast_appproperty( t, erase ) %], alphabefore ) ->> d.discovered_files_cache;
    endif
enddefine;

define lconstant peek_expr_to( closing_keyword );
    dlocal pop_syntax_only = true;
    dlocal proglist_state;
    lvars old_proglist = proglist;
    pop11_comp_expr_to( closing_keyword ) -> _;
    [%
        while old_proglist.ispair and not( old_proglist.back.isprocedure ) do
            old_proglist.destpair -> old_proglist
        endwhile;
    %]
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

define pr_show_failures( passes, failures );
    dlocal poplinewidth = false;
    nprintf( 'Test results at: ' <> sysdaytime() );
    nl(1);

    lvars i, n;
    for i, n in failures, list_from(1) do
        lvars ( u, msg, idstring, args ) = i.destfailureinfo;
        if idstring = 'unittest-assert:unittest-fail' then
            lvars name = u.pdprops;
            nprintf( '%p.\tFailed    : %p', [^n ^name] );
            if u.isclosure then
                nprintf( '\tData      : %p', [[% u.explode %]])
            endif;
            lvars (filename, linenumber, assert_expr, _n) = args.destlist;
            printf( '\tExpression: ' );
            applist( [assert ^^assert_expr], spr );
            nl(1);
            nprintf( '\tLine num  : %p', [ ^linenumber ] );
            nprintf( '\tFile name : %p', [ ^filename ] );
        else
            lvars name = u.pdprops;
            nprintf( '%p.\tUnit test : %p', [^n ^name] );
            nprintf( '\tMessage   : %p', [ ^msg ] );
            unless args.null do
                npr( '\tInvolving : ' );
                lvars a;
                for a in args do
                    nprintf( '\t *\t%p', [^a] )
                endfor;
            endunless;
        endif;
        nl( 1 );
    endfor;
enddefine;

define pr_show_discovered( d );
    dlocal poplinewidth = false;
    nprintf( 'Test discovery at: ' <> sysdaytime() );
    nl( 1 );

    nprintf( 'Unittests discovered (total of %p)', [% d.discovered_unittests.length %] );

    lvars u, n;
    for u, n in d.discovered_unittests, list_from(1) do
        nprintf( '%p. %p', [% n, u %] );
    endfor;
    nl(1);

    nprintf( 'Files compiled during discovery (total of %p)', [% d.discovered_files.length %] );
    lvars file, n;
    for file, n in d.discovered_files, list_from(1) do
        nprintf( '%p. %p', [% n, file %] );
    endfor;
enddefine;

endsection;
