compile_mode :pop11 +strict;

section $-unittest => 
    define_unittest 
    define_testblock
    ved_test 
    register_unittest 
    fail_unittest
    ved_tmr 
    ved_discover
    pop_unittests;

vars pop_unittests = undef;
vars unittest_passes = undef;
vars unittest_failures = undef;
vars current_unittest = undef;

;;; At top-level do nothing.
define vars register_unittest( u );
enddefine;

constant procedure registration_table =
    newanyproperty( 
        [], 8, 1, 8,
        false, false, "tmpval",
        false, false
    );

define vars register_unittest_during_discovery( u );
    lvars index = popfilename or vedpathname;
    if index do
        index -> registration_table( u );
    endif; 
    u :: pop_unittests -> pop_unittests;
enddefine;

define vars run_unittest( p );
    p();
enddefine;

define run_unittest_during_execution( p );
    dlocal current_unittest = p;
    p();
    p :: unittest_passes -> unittest_passes;
enddefine;

define vars fail_unittest();
    mishap( 'Unittest failed', [] )
enddefine;

define fail_unittest_during_execution();
    current_unittest :: unittest_failures -> unittest_failures;
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


define ved_tmr();
    lvars ( passes, failures ) = run_all_unittests( discover_unittests( ved_lmr ) );
    sprintf(
        '%p passes, %p failures',
        [% length( passes ), length( failures ) %]
    ).vedputmessage;
enddefine;

constant unittest_suffix = '.test.p';

define discover_unittest_scope();
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
        lvars t =  newanyproperty( 
            [], 8, 1, 8,
            syshash, nonop =, "perm",
            false, false
        );
        lvars u;
        for u in d.discovered_unittests do
            lvars parent = registration_table( u );
            if parent.isstring do
                true -> t( parent )
            endif
        endfor;
        nc_listsort( [% fast_appproperty( t, erase ) %], alphabefore ) ->> d.discovered_files_cache;
    endif
enddefine;

define test_discovery_in_ved();
    newdiscovered( discover_unittests( discover_unittest_scope() ) )
enddefine;

define up_from( n );
    procedure();
        n;
        n + 1 -> n;
    endprocedure.pdtolist
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
enddefine;

endsection;
