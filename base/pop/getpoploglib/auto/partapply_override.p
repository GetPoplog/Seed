compile_mode :pop11 +strict;

uses frozval_names
uses dict

section $-frozval_names => partapply_override;

define partapply_override( procedure pdr, new_frozvals ) -> c;
    dlvars c;
    consclosure( pdr.pdpart, #| pdr.explode |#) -> c;
    frozval_slot_table( pdr ) -> frozval_slot_table( c );
    if new_frozvals.islist then
        lvars i, n = 0;
        for i in new_frozvals do
            n fi_+ 1 -> n;
            i -> frozval( n, c )
        endfor;
    elseif new_frozvals.isdict then
        appdict( 
            new_frozvals, 
            procedure( k, v );
                v -> frozval( frozval_closure_slot( k, c ), c )
            endprocedure
        ), 
    else
        mishap( 'Unexpected replacement frozen values', [^new_frozvals] )
    endif
enddefine;

endsection;
