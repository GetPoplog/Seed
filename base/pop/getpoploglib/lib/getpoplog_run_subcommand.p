compile_mode :pop11 +strict;

section;

uses getpoplog;

;;; Given command line options of the form
;;;     ['--option1' '--option2=value' 'nonoption1' 'nonoption2']
;;; returns a dict and list
;;;     ${option1=true, option2=value}, [^nonoption1 ^nonoption2]
define lconstant parse_args( args );
    lvars keys = [];
    lvars values = [];
    lvars others = [%
        lvars arg;
        for arg in args do
            if isstartstring( '--', arg ) then
                lvars n = locchar( `=`, 1, arg );
                if n then
                    lvars k = consword( substring( 3, n - 3, arg ) );
                    lvars v = substring( n + 1, datalength( arg ) - n, arg );
                    conspair( k, keys ) -> keys;
                    conspair( v, values ) -> values;
                else
                    lvars k = consword( substring( 3, datalength( arg ) - 2, arg ) );
                    conspair( k, keys ) -> keys;
                    conspair( true, values ) -> values;
                endif
            else
                arg
            endif 
        endfor;
    %];
    return( newdict_from_twinlists(keys, values), others )
enddefine;

define getpoplog_run_subcommand();
    if poparglist.null then
        dlocal cucharout = cucharerr;
        npr( 'Expected name of subcommand but none was given' );
        false -> pop_exit_ok;
        sysexit();
    else
        lvars (subcmd, args) = poparglist.dest;
        lvars w = consword( 'getpoplog_subcommand_' <> subcmd );
        if sys_autoload( w ) then
            valof( w )( parse_args( args ) )
        else
            dlocal cucharout = cucharerr;
            pr( 'Cannot autoload a subcommand with this name and arguments: ' );
            pr( subcmd );
            applist( args, procedure(a); pr( space ); pr( a ) endprocedure );
            pr( newline );
            false -> pop_exit_ok;
            sysexit();
        endif
    endif
enddefine;

getpoplog_run_subcommand();

endsection;
