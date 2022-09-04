compile_mode :pop11 +strict;

section;

;;; WARNING!
procedure();
    dlocal cucharout = cucharerr;
    npr( ';;; EXPERIMENTAL LIBRARY WARNING - named_arguments' )
endprocedure();

uses frozval_names;

define recalculate_offsets( fn, data );
    lvars ( detect_dirty, names, refs ) = data.explode;
    until names.null do
        lvars name = names.dest -> names;
        lvars ref = refs.dest -> refs;
        lvars index = frozval_stack_slot( name, fn );
        index -> cont( ref );
    enduntil;
    fn -> cont( detect_dirty );
enddefine;

define plant_replace_stack_values( fn_name, names, tmpvars, refs );

    define lconstant update_stacked_values( fn_name, tmpvars, refs );
        unless tmpvars.null do
            lvars tmpvar = tmpvars.dest -> tmpvars;
            lvars ref = refs.dest -> refs;
            sysPUSH( tmpvar );
            sysPUSHQ( ref );
            sysCALL( "fast_cont" );
            sysUCALL( "subscr_stack" );
            update_stacked_values( fn_name, tmpvars, refs );
        endunless
    enddefine;

    lvars detect_dirty = consref( false );
    sysPUSHQ( detect_dirty );
    sysCALL( "fast_cont" );
    sysPUSH( fn_name );
    sysCALL( "==" );
    lvars label_update_stacked_values = sysNEW_LABEL();
    sysIFSO( label_update_stacked_values );

    sysPUSH( fn_name );
    sysPUSHQ( {% detect_dirty, names, refs %} );
    sysCALLQ( recalculate_offsets );

    sysLABEL( label_update_stacked_values );
    update_stacked_values( fn_name, tmpvars, refs );
enddefine;

define compile_with_define( bound_names, bound_tmpvars );
    dlocal pop_new_lvar_list;
    lvars fn_name = proglist.dest -> proglist;
    [
        define ^fn_name
    %
        pop11_need_nextitem( "(" );
        until proglist.null or proglist.hd == ")" do
            proglist.dest -> proglist;
        enduntil;
        lvars nm;
        for nm in bound_names do
            ",", nm
        endfor;
    % 
        ^^proglist
    ] -> proglist;
    pop11_comp_expr();
    sysPUSH( fn_name );
    sysPUSH( "popstackmark" );
    applist( bound_tmpvars, sysPUSH );
    sysCALL( "sysconslist" );
    sysCALL( "partapply" );
    sysPOP( fn_name );
    sysPUSHQ( bound_names );
    sysCALL( "destlist" );
    sysPUSH( fn_name );
    sysUCALL( "frozval_names" );
enddefine;

define syntax with;
    dlocal pop_new_lvar_list;
    lvars bound_names = [];
    lvars bound_tmpvars = [];
    lvars bound_refs = [];
    lvars token;
    until pop11_try_nextreaditem( [do define] ) ->> token do
        lvars name = readitem();    ;;; macro expansion not allowed.
        unless name.isword do
            mishap( 'Word expected', [^name] )
        endunless;
        pop11_need_nextitem( "=" ) -> _;
        pop11_comp_expr();
        lvars tmpvar = sysNEW_LVAR();
        sysPOP( tmpvar );
        pop11_try_nextreaditem( "," ) -> _;
        tmpvar :: bound_tmpvars -> bound_tmpvars;
        name :: bound_names -> bound_names;
        consref( false ) :: bound_refs -> bound_refs;
    enduntil;
    if token == "do" then
        lvars next = pop11_comp_prec_expr( 0, false );
        lvars fn_name = sysNEW_LVAR();
        sysPOP( fn_name );
        if next /== "(" then
            mishap( 'Missing (', [^next] )
        endif;
        pop11_comp_prec_expr( 241, false ) -> _;
        sysPUSH( fn_name );
        sysCALL( "explode" );
        plant_replace_stack_values( fn_name, bound_names, bound_tmpvars, bound_refs );
        sysPUSH( fn_name );
        sysCALL( "pdpart" );
        sysCALL( "fast_apply" );
    elseif token == "define" then
        compile_with_define( bound_names, bound_tmpvars )
    else
        mishap( 'Unexpected end of expression', [^token] )
    endif
enddefine;

endsection;
