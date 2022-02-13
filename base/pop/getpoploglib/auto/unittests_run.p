compile_mode :pop11 +strict;

uses define_unittest;

section $-unittest =>
    unittests_discover      ;;; performs test-discovery at Pop-11 prompt
    unittests_run           ;;; performs test discovery-and-execution at Pop-11 prompt
;

define find_unittest_files( location );
    if hasendstring( location, unittest_suffix ) then
        [% location %]
    elseif hasendstring( location, '.p' ) then
        lvars dir = sys_fname_path( location );
        lvars name = sys_fname_nam( location ) <> unittest_suffix;
        sys_file_match( name, dir dir_>< '../*/', false, false ).pdtolist;
    elseif sysisdirectory( location ) then
        lvars folder = sys_fname_path( location );
        sys_file_match( folder dir_>< '.../', '*' <> unittest_suffix, false, false ).pdtolist
    else 
        []
    endif.expandlist
enddefine;

define find_unittests( location );
    lvars files = find_unittest_files( location );
    lvars tests = applist(% files, loadcompiler %).discover_unittests;
    return( newdiscovered( tests ) )
enddefine;

define unittests_discover( location );
    lvars d = find_unittests( location );
    pr_show_discovered( d );
enddefine;

define unittests_run( location );
    lvars d = find_unittests( location );

    dlocal run_unittest = run_unittest_during_execution;
    dlocal fail_unittest = fail_unittest_during_execution;
    lvars disco = d.discovered_unittests;
    lvars ( passes, failures ) = run_all_unittests( disco );

    pr_show_failures( passes, failures );
enddefine;

endsection;
