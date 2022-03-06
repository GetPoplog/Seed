;;; Summary: Named (or optional) arguments library.
;;; Version: 1.1

;;; Version 1.2
;;; Added in define_optargs. Note that the default values are calculated TO BE CONTINUED
;;;

/*
Usage pattern

    f( E1, E2 ..., Em -&- K1 = OptE1, K2 = OptE2, ..., Kn = OptEn )

    lvars_named_args a, b, c -&- gc = "perm", eq = false, hash = false;

Implementation scheme.  We arrange for -&- to leave the
keywords in SORTED order.  Here's a summary

    -&- K1 = V1, K2 = V2, ..., K = Vn

    where   n >= 1
    and     K1 ... Kn are all distinct

turns into

    V'1, K'1, V'2, K'2, ...., V'n, K'n, n, OPTIONAL_ARGUMENT_MARK

    where   K'1 < K'2 < ... < K'n
    and     K'1 ... K'n is a permutation of K1, ..., Kn
    and     V'1 ... V'n is the same permutation of V1, ... Vn

NOTE 1
------
We also have mandatory named arguments, indicated by an omission
of the defaults. These must be provided using the optional arguments
mechanism. e.g.

    ;;; The  following can only be satisfied by a stack that looks like:
    ;;; VALUE_FOR_ALPHA, VALUE_FOR_BETA, "beta", 1, OPTIONAL_ARGUMENT_MARK
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
values can only appear in define:optargs.

*/

compile_mode :pop11 +strict;

uses int_parameters;
uses pop11_named_arg_mark;

section $-gospl$-named_args =>
    lvars_named_args,           ;;; Syntax for argument processing.
;

define sort_vk_list( vk_list, direction );
    syssort(
        vk_list,
        true,
        if direction == "ascending" then
            procedure( kw1, kw2 ) with_props compare_keywords;
                kw1.vk_keyword.order_of_appearance <= kw2.vk_keyword.order_of_appearance
            endprocedure
        elseif direction == "descending" then
            procedure( kw1, kw2 ) with_props compare_keywords;
                kw1.vk_keyword.order_of_appearance >= kw2.vk_keyword.order_of_appearance
            endprocedure
        else
            mishap( direction, 1, 'Invalid direction (internal error)' )
        endif
    )
enddefine;

;;;
;;; Is there a way to write this faster?  This is called at run
;;; time to determine whether or not there are any named
;;; arguments.
;;;
define named_arg_available_rt();
    if stacklength() == 0 then
        false
    elseif dup() == pop11_named_arg_mark then
        erase(); true
    else
        false
    endif
enddefine;


define complain_about_keyword_rt( actual_keyword );
    mishap( actual_keyword, 1, 'Unrecognized keyword for named arguments' )
enddefine;

define figure_out_complaint_rt( actual_keyword, required_keyword );
    if actual_keyword == required_keyword then
        ;;; The problem must be the keyword underneath!
        complain_about_keyword_rt( /* actual */ )
    else
        complain_about_keyword_rt( actual_keyword )
    endif
enddefine;

define complain_without_nondefaults_rt( kw, count );
    if count == 0 then
        ;;; We ate them all - but there are more to come.
        lvars extra_kw = ();
        mishap( extra_kw, 1, 'Superfluous keyword argument provided' )
    else
        ;;; We didn't eat all the keywords, so it is this one
        ;;; that is the problem.
        complain_about_keyword_rt( kw )
    endif
enddefine;

define complain_with_nondefaults_rt( kw, count, bitmask, keyword_list );
    if count == 0 and bitmask.isinteger and bitmask > 0 then
        lvars posn = bitmask.integer_leastbit;
        mishap( subscrl( posn + 1, keyword_list ), 1, 'Required keyword parameter was not supplied' )
    else
        complain_without_nondefaults_rt( kw, count )
    endif
enddefine;

define complain_no_keyword_args_rt( list );
    mishap( 'No keyword arguments supplied (some are mandatory)', list );
enddefine;

define listlength_==_1( x );
    not( null( x ) ) and null( fast_back( x ) )
enddefine;


define all_bits_set( pow );
    1 << pow - 1
enddefine;

define all_but_1_bit_set( pow, posn ) -> answer;
    false -> testbit( all_bits_set( pow ), posn ) -> answer
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


define get_args( closers, opt_allowed );
    lvars bitposn = 0;
    [%
        until pop11_try_nextitem( closers ) do
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
            unless variable == "," do
                lvars keyword = (
                    if pop11_try_nextreaditem( rename_separator ) then
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
                    if pop11_try_nextitem( key_value_separator ) then
                        pop11_comp_expr();
                        sysPOP( variable );
                    else
                        bitposn -> keyword.opt_allowed;
                        bitposn + 1 -> bitposn;
                    endif
                endif;
                new_vk( variable, keyword )
            endunless
        enduntil;
    %]
enddefine;

;;;
;;; This is a poor man's class declaration.
;;;
defclass namedargstate {
    state_optional_args,
    state_nargs_optional,
    state_nondefault,

    state_nargs_nondefault,
    state_nondefault_message_list,
    state_completely_finished,
    state_tidy_finish,
    state_restart_label,
    state_count_var,
    state_nondefault_bitmask,
    state_keyword_var
};

;;;
;;; And this is its constructor.
;;;
define newnamedargstate( optional_args, nargs_optional, nondefault ) -> S;

    define make_list_from_bitposn( nargs_nondefault, nondefault );
        lvars v = initv( nargs_nondefault );
        fast_appproperty(
            nondefault,
            procedure( kw, bitposn );
                kw -> v( bitposn + 1 )
            endprocedure
        );
        v.destvector.conslist
    enddefine;

    consnamedargstate(
        optional_args, nargs_optional, nondefault,
        dupnum( false, 8 )
    ) -> S;

    nondefault.datalength -> S.state_nargs_nondefault;
    make_list_from_bitposn( S.state_nargs_nondefault, S.state_nondefault ) -> S.state_nondefault_message_list;
    sysNEW_LABEL() -> S.state_completely_finished;
    sysNEW_LABEL() -> S.state_tidy_finish;
    sysNEW_LABEL() -> S.state_restart_label;
    sysNEW_LVAR() -> S.state_count_var;
    (
        S.state_nargs_nondefault == 1 and S.state_nargs_optional > 1 or
        S.state_nargs_nondefault >= 2
    ) and sysNEW_LVAR() -> S.state_nondefault_bitmask;
    sysNEW_LVAR() -> S.state_keyword_var;
enddefine;

define plant_set_up_nondefault_bitmask( S );
    if S.state_nondefault_bitmask then
        ;;; Now set up a nondefault_bitmask.
        sysPUSHQ( all_bits_set( S.state_nargs_nondefault ) );
        sysPOP( S.state_nondefault_bitmask );
    endif;
enddefine;

define plant_check_keyword_args( S );
    if S.state_nargs_nondefault >= 1 then
        ;;;
        ;;; There are mandatory keyword arguments hence
        ;;; the stack should be headed by the named-arg-marker so we
        ;;; don't have to worry about an empty stack in this
        ;;; case.
        ;;;
        sysPUSHQ( pop11_named_arg_mark );
        sysCALL( "==" );
        lvars lab = sysNEW_LABEL();
        sysIFSO( lab );
        sysPUSHQ( S.state_nondefault_message_list );
        sysCALLQ( complain_no_keyword_args_rt );
        sysLABEL( lab );
    else
        ;;; We cannot rely on there being anything on the stack.
        sysCALLQ( named_arg_available_rt );
        sysIFNOT( S.state_completely_finished );
    endif;
enddefine;

define plant_1_optional_args( S );
    ;;;
    ;;; Special case a single optional argument because it
    ;;; can be processed more compactly.  Also we don't
    ;;; have to bother about checking for nondefaults -
    ;;; because we are guaranteed that there is at least
    ;;; one value/key pair on the stack.
    ;;;
    lvars oarg = S.state_optional_args.hd;
    sysPOP( oarg.vk_variable );         ;;; OK to assign without checking!

    ;;; Now check!
    lvars lab = sysNEW_LABEL();
    plant_eq( S.state_keyword_var, oarg.vk_keyword );
    sysAND( lab );
    plant_eq( S.state_count_var, 1 );
    sysLABEL( lab );
    sysIFSO( S.state_tidy_finish );

    sysPUSH( S.state_keyword_var );
    sysPUSHQ( oarg.vk_keyword );
    sysCALLQ( figure_out_complaint_rt );
enddefine;

define plant_clear_bit( S, keyword );
    lvars bit_posn = state_nondefault( S )( keyword );
    if bit_posn then
        ;;; Clear the relevant bit in the mask.
        ;;;     mask fi_&& 11110111 -> mask
        ;;;                    ^ bitposn
        lvars and_mask = all_but_1_bit_set( S.state_nargs_nondefault, bit_posn );
        if and_mask == 0 then
            ;;; trivial optimization if there is only 1 nondefault.
            sysPUSHQ( 0 )
        else
            sysPUSH( S.state_nondefault_bitmask );
            sysPUSHQ( and_mask );
            sysCALL(
                if S.state_nargs_nondefault <= pop_max_int.integer_length then
                    "fi_&&"
                else
                    "&&"
                endif
            );
        endif;
        sysPOP( S.state_nondefault_bitmask );
    endif;
enddefine;

define plant_many_optional_args( S );
    lvars vl = sysNEW_LVAR();
    sysPOP( vl );

    lvars done = sysNEW_LABEL();
    lvars oarg_tails;
    for oarg_tails on sort_vk_list( S.state_optional_args, "descending" ) do
        lvars ( oarg, rest ) = oarg_tails.dest;
        lvars next_lab = sysNEW_LABEL();
        plant_eq( S.state_keyword_var, oarg.vk_keyword );
        sysIFNOT( next_lab );
        sysPUSH( vl );
        sysPOP( oarg.vk_variable );
        plant_fast_decrement( S.state_count_var );
        plant_clear_bit( S, oarg.vk_keyword );
        unless null( rest ) do
            plant_eq( S.state_count_var, 0 );
            sysIFSO( done );
            sysPOP( S.state_keyword_var );
            sysPOP( vl );
        endunless;
        sysLABEL( next_lab );
    endfor;

    sysLABEL( done );

    plant_eq( S.state_count_var, 0 );
    if S.state_nondefault_bitmask then
        lblock
            lvars lab = sysNEW_LABEL();
            sysAND( lab );
            plant_eq( S.state_nondefault_bitmask, 0 );
            sysLABEL( lab );
        endlblock
    endif;
    sysIFSO( S.state_tidy_finish );

    sysPUSH( S.state_keyword_var );
    sysPUSH( S.state_count_var );
    if S.state_nondefault_bitmask then
        if S.state_nondefault_bitmask then sysPUSH else sysPUSHQ endif( S.state_nondefault_bitmask );
        sysPUSHQ( S.state_nondefault_message_list );
        sysCALLQ( complain_with_nondefaults_rt );
    else
        sysCALLQ( complain_without_nondefaults_rt );
    endif
enddefine;

define plant_optional_args( S );

    plant_set_up_nondefault_bitmask( S );
    plant_check_keyword_args( S );

    sysLABEL( S.state_restart_label );
    sysPOP( S.state_count_var );

    ;;; Guaranteed to be at least one pair of K, V underneath
    ;;; Keep the keyword and value in variable.
    sysPOP( S.state_keyword_var );

    if S.state_nargs_optional == 1 then
        plant_1_optional_args( S );
    else
        plant_many_optional_args( S );
    endif;

    sysLABEL( S.state_tidy_finish );

    #_IF true
        sysCALLQ( named_arg_available_rt );
        sysIFSO( S.state_restart_label );
    #_ENDIF

    sysLABEL( S.state_completely_finished );
enddefine;

define syntax lvars_named_args;
    dlocal pop_new_lvar_list;

    lvars positional_args = get_args( "-&-", false );

    lvars nondefault = newproperty( [], 16, false, "perm" );
    lvars optional_args = get_args( ";", nondefault );
    lvars nargs_optional = optional_args.length;

    unless nargs_optional == 0 do
        plant_optional_args( newnamedargstate( optional_args, nargs_optional, nondefault ) );
    endunless;

    ;;; Now pop the mandatory args.
    applist( positional_args.rev, vk_variable <> sysPOP );
    ";" :: proglist -> proglist;
enddefine;


endsection;

/*

define evil1();
    lvars_named_args -&- xxx;
enddefine;

define foo() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no";
    [ ^x ^y ^a ^b ] =>
enddefine;

define bar() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no", mmm;
    [ ^x ^y ^a ^b ^mmm ] =>
enddefine;

define gort() with_nargs 2;
    lvars_named_args x, y -&- a = false, b = "no", mmm, nnn;
    [ ^x ^y ^a ^b ^mmm ^nnn ] =>
enddefine;

define evil2();
    lvars_named_args -&- yyy;
enddefine;


foo( "x", "y" );
foo( "x", "y" -&- a = "AAA" );
foo( "x", "y" -&- b = "BBB" );
foo( "x", "y" -&- b = "BBB", a = "AAA" );

bar( "x", "y" -&- mmm = "MMM" );
bar( "x", "y" -&- a = "AAA", mmm = "MMM" );
bar( "x", "y" -&- b = "BBB",  mmm = "MMM" );

gort( "x", "y" -&- nnn = "NNN", mmm = "MMM" );
gort( "x", "y" -&- );

*/
