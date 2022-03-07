compile_mode :pop11 +strict;

uses lvars_named_args;

section $-gospl$-named_args =>
    define_optargs
    ;


define :define_form optargs;
    lvars id_name;
    lvars global_p = false;
    lvars decl_p = false;
    lvars idprops = 0;
    lvars passign_p = sysPASSIGN;
    repeat
        lvars item = readitem();
        if item == termin then
            mishap( 'Unexpected end of input', [] )
        elseif item == "procedure" then
            item -> idprops
        elseif item == "global" then
            sysGLOBAL -> global_p;
        elseif item == "lconstant" then
            sysLCONSTANT -> decl_p;
        elseif item == "lvars" then
            sysLVARS -> decl_p;
        elseif item == "constant" then
            sysCONSTANT -> decl_p;
        elseif item == "vars" then
            sysVARS -> decl_p;
        elseif item == "dlocal" then
            sysLOCAL -> decl_p
        elseif item == "updaterof" then
            sysUPASSIGN -> passign_p
        elseif item == "(" then
            quitloop
        elseif item.isword then
            lvars ips = item.identprops;
            if ips == 0 or ips == "undef" then
                item -> id_name;
            else
                mishap( 'Name is not an ordinary identifier', [ ^item ] )
            endif
        else
            mishap( 'Unexpected item, while looking for identifier to define', [% item, item.isword, identprops(item) %] )
        endif
    endrepeat;
    pop11_define_declare( id_name, global_p, decl_p, idprops );
    lvars nargs = get_optargs_nargs( [ -&- ) ] );
    sysPROCEDURE( id_name, nargs );
    pop11_declare_optargs( ")" );
    pop11_comp_stmnt_seq_to( "enddefine" ) -> _;
    passign_p( sysENDPROCEDURE(), id_name );
enddefine;


endsection;
