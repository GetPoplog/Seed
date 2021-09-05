compile_mode :pop11 +strict;

section;

define lconstant counting_stringin( input, start ) -> rep;
    unless start.isinteger and input.isstring do
        mishap( 'Invalid inputs for counting_stringin', [ ^input ^offset ] )
    endunless;
    lvars counter = consref( start );
    lvars N = input.datalength;
    procedure();
        if N fi_>= counter.fast_cont then
            fast_subscrs( counter.fast_cont, input );
            counter.fast_cont fi_+ 1 -> counter.fast_cont;
        else
            termin
        endif
    endprocedure -> rep;
    conspair( "repeater", counter ) -> rep.pdprops;
enddefine;

define lconstant get_count( p );
    p.pdprops.back.cont
enddefine;

define $_string_key( istring );
    lvars N = 1;
    repeat
        lvars N1 = issubstring( '{', N, istring );
        quitunless( N1 );
        N1 + 1 -> N1;
        lvars procedure r = counting_stringin( istring, N1 );
        procedure( r );
            dlocal proglist_state = proglist_new_state( r );
            dlocal pop_syntax_only = true;
            pop11_comp_expr_to( "}" ) -> _;
        endprocedure( r );
        lvars count = r.get_count;
        lvars qstring = substring( N, N1 - N - 1, istring );
        if N1 + count - 1 >= istring.datalength then
            count + 1 -> count;
        endif;
        count - 2 -> count;
        lvars bstring = substring( N1, count, istring );
        dlocal pop_pr_quotes = true;
        [ quoted ^qstring ] =>
        [ code ^bstring ] =>
        N1 + count + 1 -> N;
    endrepeat;
    [last % substring( N, istring.datalength - N + 1, istring ) %] =>
enddefine;

endsection;
