compile_mode :pop11 +strict;

section $-json => json_print json_pprint;

define json_print_char( ch );
    if ch == '"' or ch == `\\` then
        cucharout( `\\` );
        cucharout( ch );
    elseif ch == '\n' then
        cucharout( `\\` );
        cucharout( `n` );
    elseif ch == '\r' then
        cucharout( `\\` );
        cucharout( `r` );
    elseif ch == '\t' then
        cucharout( `\\` );
        cucharout( `t` );
    elseif ch == '\b' then
        cucharout( `\\` );
        cucharout( `b` );
    elseif ch < 32 or ch > 127 then
        cucharout( `\\` );
        cucharout( `u` );
        dlocal pop_pr_radix = 16;
        pr( ch && 16:F );
        pr( ( ch >> 4 ) && 16:F );
        pr( ( ch >> 8 ) && 16:F );
        pr( ( ch >> 12 ) && 16:F );
    else
        cucharout( ch )
    endif
enddefine;

define json_print_string( s );
    cucharout( '"' );
    appdata( s, json_print_char );
    cucharout( '"' );
enddefine;

vars
    MAIN_SEP = ',\n',
    ALT_SEP = '\n',
    TAB_WIDTH = 4;

define prindent( n );
    repeat TAB_WIDTH * n times cucharout( '\s' ) endrepeat
enddefine;

define prsep( sep );
    sys_syspr( sep and ALT_SEP or MAIN_SEP );
enddefine;

define pprjson( x, indent, sep );
    if x.isstring or x.isword then
        prindent( indent );
        json_print_string( x );
        prsep( sep )
    elseif x.isnumber then
        prindent( indent );
        sys_syspr( x );
        prsep( sep );
    elseif x.isboolean then
        prindent( indent );
        sys_syspr( x and 'true' or 'false' );
        prsep( sep )
    elseif x == undef or x.isundef then
        prindent( indent );
        sys_syspr( 'null' );
        prsep( sep )
    elseif x.islist then
        ;;; Array
        prindent( indent );
        cucharout( '[' );
        prsep( true );
        lvars tail;
        for tail on x do
            pprjson( front( tail ), indent+1, null( tail.back ) );
        endfor;
        prindent( indent );
        cucharout( ']' );
        prsep( sep );
    elseif x.isvectorclass then
        ;;; Array
        prindent( indent );
        cucharout( '[' );
        prsep( true );
        lvars i, n, L = datalength( x );
        for i with_index n in_vectorclass x do
            pprjson( i, indent+1, n == L );
        endfor;
        prindent( indent );
        cucharout( ']' );
        prsep( sep );
    elseif x.isdict then
        ;;; Object
        prindent( indent );
        cucharout( '{' );
        prsep( true );
        dlvars count = 0;
        dlvars N = dict_length( x );
        appdict(
            x,
            procedure( k, v );
                count + 1 -> count;
                prindent( indent + 1 );
                json_print_string( k );
                cucharout( `:` );
                prsep( ALT_SEP );
                pprjson( v, indent+2, count == N );
            endprocedure
        );
        prindent( indent );
        cucharout( '}' );
        prsep( sep );
    else
        prindent( indent );
        sys_syspr( x );
        prsep( sep );
    endif
enddefine;

define json_pprint( x );
    dlocal TAB_WIDTH = 4;
    dlocal MAIN_SEP = ',\n';
    dlocal ALT_SEP = '\n`';
    dlocal poplinewidth = false;
    dlocal poplinemax = false;
    pprjson( x, 0, ALT_SEP )
enddefine;

define json_print( x );
    dlocal TAB_WIDTH = 0;
    dlocal MAIN_SEP = ',';
    dlocal ALT_SEP = '';
    dlocal poplinewidth = false;
    dlocal poplinemax = false;
    pprjson( x, 0, ALT_SEP )
enddefine;

endsection;
