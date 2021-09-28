compile_mode :pop11 +strict;

section $-unittest => 
    define_unittest 
    ved_test 
    register_unittest 
    fail_unittest
    ved_discover
    pop_unittests
    assert;

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
    u :: pop_unittests -> pop_unittests;
enddefine;

;;; Part of test-execution.
;;; This is defensive - we only want to run unit tests inside an appropriate
;;; dynamic context.
define vars run_unittest( p );
    mishap( 'Trying to trace unit tests with context (this should never happen)', [] )
enddefine;

;;; This is the normal way to run a unit test & we will dlocalise run_unittest
;;; to its value.
define run_unittest_during_execution( p );

    define dlocal pop_exception_final( N, mess, idstring, severity );
        returnunless( severity == `E` or severity == `R` )( false );
        lvars args = conslist( N );
        chain( [ ^mess ^idstring ^args ], fail_unittest ) 
    enddefine;

    dlocal current_unittest = p;
    p();
    p :: unittest_passes -> unittest_passes;
enddefine;

;;; Part of test-execution.
;;; This will only be invoked at top-level and hence outside of a test
;;; context, so it is OK for it to simply mishap.
define vars fail_unittest( info );
    mishap( 'Unittest failed', [] )
enddefine;

define fail_unittest_during_execution( info );
    conspair( current_unittest, info ) :: unittest_failures -> unittest_failures;
    exitfrom( run_unittest )
enddefine;

define discover_unittests( p );
    dlocal pop_unittests = [];
    dlocal register_unittest = register_unittest_during_discovery;
    erasenum(#| p() |#);
    return( pop_unittests )
enddefine;

define run_all_unittests( unittest_list );
    dlocal unittest_passes = [];
    dlocal unittest_failures = [];
    applist( unittest_list, run_unittest );
    ( unittest_passes, unittest_failures )
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
                quitif( item == ";" );               
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

    if pdrname == ";" then
        sysNEW_LVAR() -> pdrname;
        false -> is_global;
        procedure( w, n ); endprocedure -> declarator;
    endif;
enddefine;

define :define_form global unittest;
    lvars ( pdrname, is_global, declarator ) = read_declaration( unittest_sysVARS );
    declarator( pdrname.isword and pdrname, 0 );
    if is_global then sysGLOBAL( pdrname, is_global ) endif;
    sysPROCEDURE( pdrname, 0 );

    ;;; Set up dynamic test discovery.
    sysLOCAL( "pop_unittests" );
    sysPUSH( "nil" );
    sysPOP( "pop_unittests" );
    sysLOCAL( "register_unittest" );
    sysPUSHQ( procedure(u); u :: pop_unittests -> pop_unittests endprocedure );
    sysPOP( "register_unittest" );

    ;;; Main body.
    pop11_comp_stmnt_seq_to( "enddefine" ) -> _;
  
    ;;; Run any registered tests.
    sysPUSH( "pop_unittests" );
    sysPUSHQ( run_unittest );  
    sysCALL( "applist" );
  
    sysPASSIGN( sysENDPROCEDURE(), pdrname );
    sysPUSH( pdrname );
    sysCALL( "register_unittest" );
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

define global syntax assert();

    define lconstant check_assertion( N );
        if N == 0 then
            mishap( 0, 'No results from assertion', 'unittest-assert:stack-empty' )
        elseif N > 2 then 
            mishap( N, 'Too many results from assertion', 'unittest-assert:stack-many' )
        else
            lvars result = ();
            unless result do
                mishap( 0, 'Assertion failed', 'unittest-assert:unittest-fail' )
            endunless
        endif
    enddefine;

    dlocal pop_new_lvar_list;
    lvars t = sysNEW_LVAR();
    sysCALL( "stacklength" );
    sysPOP( t );
    pop11_comp_expr_to( ";" ) -> _;
    sysCALL( "stacklength" );
    sysPUSH( t );
    sysCALL( "fi_-" );
    sysCALLQ( check_assertion );
enddefine;

;;; -- VED integration ---

define select_scope_for_vedargument();
    if vedargument = '' then
        if hasendstring( vedcurrent, unittest_suffix ) then            
            ved_l1
        elseif hasendstring( vedcurrent, '.p' ) then  
            lvars dir = sys_fname_path( vedcurrent ); 
            lvars name = sys_fname_nam( vedcurrent ) <> unittest_suffix;
            procedure();
                lvars file;
                for file in sys_file_match( name, dir dir_>< '../*/', false, false ).pdtolist do
                    vedputmessage( 'COMPILING ' >< file );
                    pop11_compile( file )
                endfor
            endprocedure
        else    
            mishap( 'No tests found', [vedargument ^vedargument vedcurrent ^vedcurrent] )
        endif
    else
        lvars folder = sys_fname_path( vedcurrent ); 
        procedure();
            lvars file;
            for file in sys_file_match( folder, '*' <> unittest_suffix, false, false ).pdtolist do
                vedputmessage( 'COMPILING ' >< file );
                pop11_compile( file )
            endfor
        endprocedure
    endif 
enddefine;

define test_discovery_in_ved();
    newdiscovered( discover_unittests( select_scope_for_vedargument() ) )
enddefine;

define up_from( n );
    procedure();
        n;
        n + 1 -> n;
    endprocedure.pdtolist
enddefine;

define show_failures( passes, failures );
    dlocal vedpositionstack;
    lvars d = test_discovery_in_ved();

    vededit( '*TEST RESULTS*', procedure(); vedhelpdefaults(); false -> vedbreak; endprocedure );
    ved_clear();
    vedpositionpush();
    dlocal cucharout = vedcharinsert;

    nprintf( 'Test results at: ' <> sysdaytime() );
    nl(1);

    lvars p;
    for p, n in failures, up_from(1) do
        lvars ( u, mishap_details ) = p.destpair;
        lvars ( msg, idstring, args ) = mishap_details.dl;
        lvars name = u.pdprops;
        nprintf( '%p.\tUnit test: %p', [^n ^name] );
        nprintf( '\tMessage  : %p', [ ^msg ] );
        unless args.null do
            npr( 'Argument: ' );
            lvars a;
            for a in args do
                nprintf( '\t\t%p', [^a] )
            endfor;
        endunless;
    endfor;

    vedpositionpop();
enddefine;

define ved_discover();
    dlocal vedpositionstack;
    lvars d = test_discovery_in_ved();

    vededit( '*TESTS DISCOVERED*', procedure(); vedhelpdefaults(); false -> vedbreak; endprocedure );
    ved_clear();
    vedpositionpush();

    dlocal cucharout = vedcharinsert;
    
    nprintf( 'Test discovery at: ' <> sysdaytime() );
    nl( 1 );

    nprintf( 'Unittests discovered (total of %p)', [% d.discovered_unittests.length %] );
    ;;; vedinsertstring( sprintf( 'Unittests discovered (total of %p)', [% d.discovered_unittests.length %] ) );
    ;;; vedlinebelow();
    
    lvars u, n;
    for u, n in d.discovered_unittests, up_from(1) do
        vedinsertstring( sprintf( '%p. %p', [% n, u %] ) );
        vedlinebelow();
    endfor; 
    vedlinebelow();
    
    vedinsertstring( sprintf( 'Files compiled during discovery (total of %p)', [% d.discovered_files.length %] ) );
    vedlinebelow();
    lvars file, n;
    for file, n in d.discovered_files, up_from(1) do
        vedinsertstring( sprintf( '%p. %p', [% n, file %] ) );
        vedlinebelow();
    endfor; 
    
    vedpositionpop();
enddefine;

define ved_test();
    lvars d = test_discovery_in_ved();
    dlocal run_unittest = run_unittest_during_execution;
    dlocal fail_unittest = fail_unittest_during_execution;
    lvars ( passes, failures ) = run_all_unittests( d.discovered_unittests );
    if null(failures) then
        lvars n_passes = passes.length;
        lvars n_failures = failures.length;
        sprintf(
            '%p pass%p, %p failure%p',
            [% 
                n_passes, 
                if n_passes == 1 then '' else 'es' endif, ;;; singular v plural
                n_failures, 
                if n_failures == 1 then '' else 's' endif ;;; singular v plural
            %]
        ).vedputmessage;
    else
        show_failures( passes, failures )
    endif;
enddefine;

endsection;
