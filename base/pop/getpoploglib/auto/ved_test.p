compile_mode :pop11 +strict;

uses define_unittest;

section $-unittest =>
    ved_test                ;;; discovery and execution
    ved_discover            ;;; performs test-discovery
;

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
    elseif sysisdirectory( vedargument ) then
        procedure( folder );
            lvars file;
            for file in sys_file_match( folder dir_>< '.../', '*' <> unittest_suffix, false, false ).pdtolist do
                vedputmessage( 'COMPILING ' >< file );
                pop11_compile( file )
            endfor
        endprocedure(% vedargument %)
    else
        identfn(% [] %)
    endif
enddefine;

define test_discovery_in_ved();
    newdiscovered( discover_unittests( select_scope_for_vedargument() ) )
enddefine;

define show_failures( passes, failures );
    dlocal vedpositionstack;

    vededit( '*TEST RESULTS*', procedure(); vedhelpdefaults(); false -> vedbreak; endprocedure );
    ved_clear();
    vedpositionpush();
    dlocal cucharout = vedcharinsert;

    pr_show_failures( passes, failures );

    vedpositionpop();
enddefine;


define ved_discover();
    dlocal vedpositionstack;
    lvars d = test_discovery_in_ved();

    vededit( '*TESTS DISCOVERED*', procedure(); vedhelpdefaults(); false -> vedbreak; endprocedure );
    ved_clear();
    vedpositionpush();

    dlocal cucharout = vedcharinsert;

    pr_show_discovered( d );

    vedpositionpop();
enddefine;

define ved_test();
    lvars d = test_discovery_in_ved();
    dlocal run_unittest = run_unittest_during_execution;
    dlocal fail_unittest = fail_unittest_during_execution;
    lvars disco = d.discovered_unittests;
    lvars ( passes, failures ) = run_all_unittests( disco );

    unless null(failures) then
        show_failures( passes, failures )
    endunless;

    lvars n_passes = passes.length;
    lvars n_failures = failures.length;
    dlocal pop_pr_quotes = false;
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
