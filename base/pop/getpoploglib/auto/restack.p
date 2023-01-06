;;; Summary: syntax word for manipulating top items of stack

compile_mode :pop11 +strict;

section $-restack =>
    restack
    sysRESTACK
    ;

;;; Reads a (optionally comma separated) list of ordinary variables from
;;; the input stream.
define read_variables();
    [%
        repeat
            quitif( proglist.null );
            lvars item = proglist.hd;
            quitunless( item.isword );
            if item == "," then
                readitem().erase;
                nextloop;
            endif;
            lvars id = identprops( item );
            quitunless(
                id.isnumber or
                id == "undef" or
                id == "procedure" or
                id == "macro"
            );
            readitem();
        endrepeat
    %]
enddefine;

define lconstant oops( i ); lvars i;
    mishap( 'RESTACK: INTERNAL ERROR (please report)', [^i] )
enddefine;

define lconstant sanity_check( inputs, outputs ) -> ( arity, indexes );
    lvars inputs, outputs, arity, indexes;
    0 -> arity;
    lvars i, t;
    for i on inputs do
        if lmember( dest( i ) ) do
            mishap( 'RESTACK: input variable used twice', [% hd(i) %] )
        else
            arity + 1 -> arity;
        endif
    endfor;
    [%
        for i in outputs do
            if lmember( i, inputs ) ->> t then
                arity - length( t ) + 1
            else
                mishap( 'RESTACK: variable not in input list', [^i] )
            endif
        endfor;
    %] -> indexes;
enddefine;

;;; A plan consists of a series of instructions of the form
;;;     [POP n], [PUSH n], [PUSHS], [ERASE], [SWAP m n], [CHECK n]
;;; These correspond to VM instructions, with the exception of [CHECK k]
;;; whose role is to check there are at least k items on the stack.
;;;
define lconstant naive_plan( arity, indexes ); lvars arity, indexes;
    [%
        lvars i;
        for i from arity by -1 to 1 do
            [POP ^i]
        endfor;
        for i in indexes do
            [PUSH ^i]
        endfor;
    %]
enddefine;

;;; This predicate is given a list of
;;; instruction types "types" and a particular instruction "this_inst".
;;; It checks whether or not the plan consists of a series of instructions
;;; of those types & then this_inst.  The instructions after that don't
;;; matter.
;;;
define lconstant up_to_inst( plan, this_inst, types );
    lvars plan, types, this_inst;
    lvars inst, count = 0;
    for inst in plan do
        if inst = this_inst then
            return( count )
        elseunless lmember( hd( inst ), types ) then
            return( false )
        endif;
        count + 1 -> count;
    endfor;
    return( false )
enddefine;

;;; This is a little predicate on plans.  Does the plan consist of a series of
;;; POP/ERASE instructions followed by a particular instruction?  It returns
;;; either the number of PUSH/ERASE instructions or false.
define lconstant pops_then_inst( plan, this_inst ); lvars plan, this_inst;
    up_to_inst( plan, this_inst, [POP ERASE] )
enddefine;

;;; A similar predicate to the preceding.  This time, does the plan consist
;;; of a series of SWAP instructions followed by a particular instruction?
;;; It returns the number of SWAP instructions or false.
define lconstant swaps_then_inst( plan, this_inst ); lvars plan, this_inst;
    up_to_inst( plan, this_inst, [SWAP] )
enddefine;

;;; Is there a check that can be eliminated through stack counting?
;;; We know there are at least K items on the stack.
define find_check( plan, k ); lvars plan, k;
    lvars n = 0;
    lvars i;
    for i in plan do
        n + 1 -> n;
        quitif( k <= 0 );
        lvars type = i.hd;
        if type == "ERASE" or type == "POP" then
            k - 1 -> k
        elseif type == "PUSHS" or type == "PUSH" then
            k + 1 -> k
        elseif type == "SWAP" then
            ;;; Ignore this swap.
        elseif type == "CHECK" then
            return( n )
        else
            oops( i );
        endif;
    endfor;
    return( false );
enddefine;

;;; Try to remove superfluous CHECK instructions by counting
;;; the number of items guaranteed to be on the stack.  K is the
;;; number guaranteed.
;;;
define lconstant cull_checks( plan ); lvars plan;

    define lconstant decr( n ) -> n; lvars n;
        n - 1 -> n;
        if n < 0 then 0 -> n endif
    enddefine;

    lvars K = 0;
    lvars inst;
    for inst in plan do
        lvars type = inst.hd;
        if type == "ERASE" or type == "POP" then
            decr( K ) -> K;
        elseif type == "PUSHS" or type == "PUSH" then
            K + 1 -> K;
        elseif type == "SWAP" then
            max( K, max( inst(2), inst(3) ) ) -> K;
        elseif type == "CHECK" then
            nextif( K >= 1 );
            1 -> K;
        else
            oops( inst );
        endif;
        ;;; We push every instruction apart from that of CHECK.
        ;;; CHECK will sometimes skip this by calling "nextif".
        inst;
    endfor;
enddefine;

;;; Peephole optimisation of restacking plan.  There are several different
;;; kinds of simple improvement made in this routine.
;;; 1.  Any POP n without a subsequent PUSH n becomes an ERASE
;;; 2.  POP n & PUSH n without subsequent references to n --> [CHECK]
;;; 3.  POP n & POP/ERASE ... & PUSH n without a subsequent reference to n
;;;     improved into a SWAP.
;;; 4.  POP n & SWAPS... & PUSH n --> +SWAPS... & POP n & PUSH n
;;; 5.  (PUSHS | PUSH n) & ERASE --> ()
;;; 6.  PUSH n & PUSH n ... --> PUSH n & PUSHS ...
;;; 7.  SWAP a b & SWAP a b --> ()
;;; 8.  CHECK & ( CHECK/PUSHS/ERASE/POP n/SWAP a b) --> ( ... )
define lconstant improved( plan ); lvars plan, n;
    until null( plan ) do
        lvars inst = plan.dest -> plan;
        lvars ( type, arg ) = inst.dest;
        lvars next_inst = if plan.null then [DUMMY] else plan.hd endif;
        lvars ( next_type, next_arg ) = next_inst.dest;
        if type == "POP" then
            lvars index = arg( 1 );
            lvars push = [ PUSH ^index ];
            if not( member( push, plan ) ) then
                [ ERASE ]
            elseif
                next_inst = push and
                ( null( plan ) or not( member( push, plan.tl ) ) )
            then
                plan.tl -> plan;
                [CHECK]
            elseif
                next_inst /= push and
                ( pops_then_inst( plan, push ) ->> n ) and
                not( member( push, applynum( plan, tl, n+1 ) ) )
            then
                [SWAP 1 ^(n+1)];        ;;; insert swap
                plan( n );              ;;; move last POP/ERASE to start
                repeat n - 1 times
                    plan.dest -> plan   ;;; remaining POP/ERASE
                endrepeat;
                plan.tl -> plan;        ;;; don't reuse last POP/ERASE
                plan.tl -> plan;        ;;; dispose of PUSH
            elseif
                next_inst /= push and
                ( swaps_then_inst( plan, push ) ->> n )
            then
                repeat n times
                    lvars swap_inst = plan.dest -> plan;
                    [SWAP % swap_inst(2)+1, swap_inst(3)+1 %]
                endrepeat;
                inst;
            else
                inst
            endif
        elseif type == "PUSH" or type == "PUSHS" then
            if next_type == "ERASE" then
                plan.tl -> plan
            elseif type == "PUSH" and next_inst = inst then
                inst;
                while not(plan.null) and plan.hd = inst do
                    [PUSHS];
                    plan.tl -> plan;
                endwhile;
            else
                inst
            endif
        elseif type == "SWAP" then
            if inst = next_inst then
                ;;; two swaps in a row ... do nothing.
                plan.tl -> plan;
            else
                lvars n = find_check( plan, max( arg(1), arg(2) ) );
                inst
            endif
        elseif type == "CHECK" then
            if lmember( next_type, #_< [CHECK ERASE POP PUSHS SWAP] >_# ) then
                /* nothing -- eliminate this instruction */
            else
                inst
            endif
        else
            inst
        endif
    enduntil;
enddefine;

define lconstant optimise( plan ); lvars plan;
    repeat
        lvars i_plan = [% cull_checks( [% improved( plan ) %] ) %];
        returnif( i_plan = plan )( plan );
        i_plan -> plan;
    endrepeat
enddefine;

define lconstant plant( plan ); lvars plan;
    dlocal pop_new_lvar_list;

    lvars table = [].newassoc;

    define lconstant local( arg ); lvars arg;
        lvars index = arg.hd;
        table( index ) or
        ( sysNEW_LVAR() ->> table( index ) )
    enddefine;

    lvars inst;
    for inst in plan do
        lvars ( type, arg ) = inst.dest;
        if type == "POP" then
            sysPOP( arg.local )
        elseif type == "PUSH" then
            sysPUSH( arg.local )
        elseif type == "PUSHS" then
            sysPUSHS( undef )
        elseif type == "ERASE" then
            sysERASE( undef )
        elseif type == "SWAP" then
            sysSWAP( arg.dl )
        elseif type == "CHECK" then
            sysPUSHS( undef );
            sysERASE( undef )
        else
            oops( inst )
        endif
    endfor;
enddefine;

define sysRESTACK( inputs, outputs );
    lvars ( arity, indexes ) = sanity_check( inputs, outputs );
    naive_plan( arity, indexes ).optimise.plant;
enddefine;

define syntax restack;
    lvars inputs = read_variables();
    pop11_need_nextreaditem( "->" ).erase;
    lvars outputs = read_variables();
    sysRESTACK( inputs, outputs )
enddefine;

endsection;
