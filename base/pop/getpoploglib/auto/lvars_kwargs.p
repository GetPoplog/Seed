/*
Usage pattern

    f( E1, E2 ..., Em -&- K1 = OptE1, K2 = OptE2, ..., Kn = OptEn )

    lvars_named_args a, b, c -&- gc = "perm", eq = false, hash = false;

Implementation scheme.  We arrange for -&- to leave the
keywords in SORTED order.  Here's a summary

    -&- K1 = V1, K2 = V2, ..., K = Vn

    where   n >= 1
    and     K1 ... Kn are all distinct

turns into the following stack-pattern (from bottom to top)

    BOTTOM_MARK, BOTTOM_MARK,
    K'1, V'1, K'2, V'2, ...., K'n, V'n, 
    TOP_MARK

    where   K'1 < K'2 < ... < K'n
    and     K'1 ... K'n is a permutation of K1, ..., Kn
    and     V'1 ... V'n is the same permutation of V1, ... Vn

NOTE 1
------
We also have mandatory named arguments, indicated by an omission
of the defaults. These must be provided using the optional arguments
mechanism. e.g.

    ;;; The  following can only be satisfied by a stack that looks like:
    ;;; VALUE_FOR_ALPHA, BOTTOM_MARK, BOTTOM_MARK, "beta", VALUE_FOR_BETA, TOP_MARK
    lvars_named_args alpha -&- beta;

NOTE 2
------
The internal variables of the parameters can be distinct from their
parameter-name. To make this work use the renaming syntax. e.g.

    ;;; The following uses a keyword 'secondary' but the internal
    ;;; variable is my_list2.
    lvars_named_args my_list1 -&- my_list2/secondary = [];

NOTE 3
------
Default expressions are different from default values. Default
values can only appear in define :kwargs.

*/

compile_mode :pop11 +strict;

uses int_parameters
uses kwargs_lib

section $-kwargs =>
    lvars_kwargs,           ;;; Syntax for argument processing.
;

;;; Variable/Keyword pairs
defclass vk {
    vk_variable,
    vk_keyword
};
constant procedure new_vk = consvk;

define descending( vk1, vk2 );
    alphabefore( vk2.vk_keyword, vk1.vk_keyword )
enddefine;

define sort_vk_list( vk_list );
    syssort( vk_list, true, descending )
enddefine;

define plant_fast_decrement( count );
    sysPUSH( count );
    sysPUSHQ( 1 );
    sysCALL( "fi_-" );      ;;; Safe to use fi_- because we don't care if count becomes junk.
    sysPOP( count );
enddefine;

define plant_eq( variable, value );
    sysPUSH( variable );
    sysPUSHQ( value );
    sysCALL( "==" );
enddefine;

define get_args( closers, opt_allowed ) -> ( positional_args, closer );
    [%
        until pop11_try_nextitem( closers ) ->> closer do
            lvars is_proc = false;
            lvars is_dlocal = false;
            repeat
                lvars tok = pop11_try_nextreaditem( [ procedure dlocal ] );
                quitunless( tok );
                if tok == "procedure" then
                    true -> is_proc;
                elseif tok == "dlocal" then
                    true -> is_dlocal;
                endif
            endrepeat;

            lvars variable = readitem();
            nextif( variable == "," );

            unless variable.isword do
                mishap( 'Unexpected item in procedure header', [ ^variable ] )
            endunless;
            lvars idprops = identprops( variable );
            unless idprops == 0 or idprops == "undef" do
                mishap( 'Parameter not an ordinary word', [ ^variable ] )
            endunless;

            lvars keyword = (
                if pop11_try_nextreaditem( RENAME_SEPARATOR ) then
                    readitem()
                else
                    variable
                endif
            );
            if is_dlocal then
                sysLOCAL( variable )
            else
                sysLVARS( variable, is_proc or 0 )
            endif;
            if opt_allowed.isproperty then
                if pop11_try_nextitem( KEY_VALUE_SEPARATOR ) then
                    pop11_comp_expr();
                    sysPOP( variable );
                else
                    sysNEW_LVAR() -> keyword.opt_allowed;
                endif
            endif;
            new_vk( variable, keyword );
        enduntil;
    %] -> positional_args;
enddefine;

define plant_optional_args( optional_args, nondefault );

    define lconstant check_progress( progress, kw ) -> n;
        stacklength() -> n;
        if progress == n then
            mishap( kw, 1, 'Unrecognised keyword argument' )
        endif
    enddefine;

    define lconstant are_kwargs_present();
        stacklength() /== 0 and
        lblock 
            lvars t = ();
            t == pop_kwargs_top_mark or ( t, false )
        endlblock
    enddefine;

    define lconstant mishap_defaultless_not_initialised( uninitialised );
        mishap( uninitialised, 1, 'Defaultless named argument not assigned' )
    enddefine;

    /*define lconstant peep( k, v );
        sysPUSH( k );
        sysPUSH( v );
        sysCALLQ( procedure( k, v ); [k = ^k, v = ^v ] => endprocedure );
    enddefine;*/

    /*
        lvars tmp_uninitialised_x = "x";
        lvars tmp_uninitialised_y = "y";
    */
    fast_appproperty(
        nondefault,
        procedure( k, v );
            sysPUSHQ( k );
            sysPOP( v );
        endprocedure
    );

    /*
        if are_kwargs_present() then                            ;;; Removes the mark.
            lvars tmp_progress = false;                         ;;; Not == to any stacklength()
            lvars ( tmp_arg, tmp_kw ) = ();                     ;;; Get current couple.
    */
    lvars tmp_progress = sysNEW_LVAR();
    lvars end_of_kwargs_processing = sysNEW_LABEL();
    sysCALLQ( are_kwargs_present );
    sysIFNOT( end_of_kwargs_processing );
    sysPUSHQ( false );
    sysPOP( tmp_progress );
    lvars tmp_kw = sysNEW_LVAR();
    lvars tmp_arg = sysNEW_LVAR();
    sysPOP( tmp_arg );
    sysPOP( tmp_kw );

    /*
            while tmp_kw /== pop_kwargs_bottom_mark do
    */
    lvars while_loop_start = sysNEW_LABEL();
    lvars while_loop_end = sysNEW_LABEL();
    sysLABEL( while_loop_start );
    plant_eq( tmp_kw, pop_kwargs_bottom_mark );
    sysIFSO( while_loop_end );

    /*          
                if tmp_kw == "x" then
                    tmp_arg -> x;
                    false -> tmp_uninitialised_x;
                    () -> ( tmp_kw, tmp_arg );
                    quitif( tmp_kw == pop_kwargs_bottom_mark );
                endif;
    */
    lvars vk;
    for vk in sort_vk_list( optional_args ) do
        ;;; sysCALLQ( npr(% '>>> ' <> vk.vk_keyword.word_string % ));
        plant_eq( tmp_kw, vk.vk_keyword );
        lvars done = sysNEW_LABEL();
        sysIFNOT( done );

        sysPUSH( tmp_arg );
        sysPOP( vk.vk_variable );

        lvars tmp_uninitialised_kw = nondefault( vk.vk_keyword );
        if tmp_uninitialised_kw then
            sysPUSHQ( false );
            sysPOP( tmp_uninitialised_kw );
        endif;

        sysPOP( tmp_arg );
        sysPOP( tmp_kw );
        ;;; peep( tmp_kw, tmp_arg );

        plant_eq( tmp_kw, pop_kwargs_bottom_mark );
        sysIFSO( while_loop_end );

        sysLABEL( done );
    endfor;

    /*
                check_progress( tmp_progress, tmp_kw ) -> tmp_progress
    */
    sysPUSH( tmp_progress );
    sysPUSH( tmp_kw );
    sysCALLQ( check_progress );
    sysPOP( tmp_progress );

    /*
    sysCALLQ( 
        procedure();
            lvars L = conslist( stacklength() );
            [after ^L] =>
            L.dl
        endprocedure
    );
    */

    sysGOTO( while_loop_start );

    /*      endwhile
    */
    sysLABEL( while_loop_end );

    /*
            lvars uninitialised = tmp_uninitialised_x or tmp_uninitialised_y;
            if uninitialised then
                mishap( uninitialised, 1, 'Defaultless named argument not assigned' )
            endif
    */
    if datalength( nondefault ) > 0 then
        dlvars lab = sysNEW_LABEL();
        dlvars sys_or = erase;
        lvars uninitialised = sysNEW_LVAR();
        fast_appproperty(
            nondefault,
            procedure( kw, tmp_uninitialised_kw );
                sys_or( lab );
                sysOR -> sys_or;
                sysPUSH( tmp_uninitialised_kw );
            endprocedure
        );
        sysLABEL( lab );
        sysPOP( uninitialised );
        sysPUSH( uninitialised );
        sysIFNOT( end_of_kwargs_processing );
        sysPUSH( uninitialised );
        sysCALLQ( mishap_defaultless_not_initialised );
    endif;

    /*  endif
    */
    sysLABEL( end_of_kwargs_processing );
enddefine;

/*  Example: the code generated for `lvars_opt v, w -&- x, y, z = 99;` should look
    like this.

    define lconstant check_progress( progress, kw ) -> n;
        stacklength() -> n;
        if progress == n then
            mishap( kw, 1, 'Unrecognised named argument' )
        endif
    enddefine;

    define lconstant are_kwargs_present();
        stacklength() == 0 and () == pop_kwargs_top_mark
    enddefine;

    lvars z;
    99 -> z;
    lvars y;
    lvars x;
    lvars w;
    lvars v;

    lvars tmp_uninitialised_x = "x";
    lvars tmp_uninitialised_y = "y";

    if are_kwargs_present() then                            ;;; Removes the mark.
        lvars tmp_progress = false;                         ;;; Not == to any stacklength()
        lvars ( tmp_kw, tmp_arg ) = ();                     ;;; Get current couple.
        while tmp_kw /== pop_kwargs_bottom_mark do
            if tmp_kw == "z" then
                tmp_arg -> z;
                () -> ( tmp_kw, tmp_arg );
                quitif( tmp_kw == pop_kwargs_bottom_mark );
            endif;
            if tmp_kw == "y" then
                tmp_arg -> y;
                false -> tmp_uninitialised_y;
                () -> ( tmp_kw, tmp_arg );
                quitif( tmp_kw == pop_kwargs_bottom_mark );
            endif;
            if tmp_kw == "x" then
                tmp_arg -> x;
                false -> tmp_uninitialised_x;
                () -> ( tmp_kw, tmp_arg );
                quitif( tmp_kw == pop_kwargs_bottom_mark );
            endif;
            check_progress( tmp_progress, tmp_kw ) -> tmp_progress
        endwhile;
    endif;

    lvars uninitialised = tmp_uninitialised_x or tmp_uninitialised_y;
    if uninitialised then
        mishap( uninitialised, 1, 'Defaultless named argument not assigned' )
    endif

    () -> x;

*/

define pop11_declare_kwargs();
    dlocal pop_new_lvar_list;

    lvars ( positional_args, closer ) = get_args( [ ^KWARGS_INTRO ) ; ], false );

    lvars nondefault = newproperty( [], 16, false, "perm" );
    lvars optional_args =
        if closer == KWARGS_INTRO then
            get_args( [ ^KWARGS_INTRO ) ; ], nondefault ) -> _
        else
            []
        endif;
    lvars nargs_optional = optional_args.length;

    unless nargs_optional == 0 do
        plant_optional_args( optional_args, nondefault );
    endunless;

    ;;; Now pop the mandatory args.
    applist( positional_args.rev, vk_variable <> sysPOP );
enddefine;

define global syntax lvars_kwargs;
    pop11_declare_kwargs();
    ";" :: proglist -> proglist;
enddefine;

endsection;
