compile_mode :pop11 +strict;

section;

define lconstant check_0( before );
    lvars after = stacklength();
    unless after == before then
        lvars k = after fi_- before;
        if k < 0 then
            mishap( 'Expression consumed values, zero stack change required', [] )
        else
            lvars results = conslist( k );
            mishap( 'Expression returned too many results, exactly zero required', results );
        endif
    endunless;
enddefine;

define lconstant check_N( before, N );
    lvars after = stacklength();
    lvars k = after fi_- before;
    unless k == N then
        if k == 0 then
            mishap( sprintf( 'Expression generated no results but %p required', [^N] ), [] );
        elseif k < 0 then
            mishap( sprintf('Expression consumed values instead of returning % result(s)', [^N] ), [] )
        else
            lvars results = conslist( k );
            mishap( sprintf( 'Expression returned too many results, exactly %p required', [^N] ), results );
        endif
    endunless;
enddefine;

lconstant procedure check_1 = check_N(% 1 %);

define global constant procedure pop11_comp_N( action, N );
    dlocal pop_new_lvar_list;
    lvars tmpvar = sysNEW_LVAR();
    sysCALL( "stacklength" );
    sysPOP( tmpvar );
    action();
    sysPUSH( tmpvar );
    if N == 0 then
        sysCALLQ( check_0 )
    elseif N == 1 then
        sysCALLQ( check_1 );
    else
        sysPUSHQ( N );
        sysCALLQ( check_N );
    endif
enddefine;

endsection;
