;;; Summary: like discin <> incharline but more efficient

compile_mode :pop11 +strict;

section;

uses sysstring;

unless sysstringlen > 0 and sysstringlen.isinteger do
    mishap( 'sysstring is too big (or small)', [length ^sysstringlen] )
endunless;

define global vars procedure discinline( file ); lvars file;
    lvars dev = file.isdevice and file or sysopen( file, 0, "line" );
    procedure();
        lvars N = sysread( dev, sysstring, sysstringlen );
        if N == 0 then
            termin
        elseif subscrs( N, sysstring ) == `\n` do
            substring( 1, N fi_- 1, sysstring )
        elseif N < sysstringlen then
            substring( 1, N, sysstring )
        else
            consstring(#|
                until N fi_< sysstringlen or subscrs( N, sysstring ) == `\n` do
                    sysstring.deststring.erase;
                    sysread( dev, sysstring, sysstringlen ) -> N;
                enduntil;
                lvars n;
                fast_for n from 1 to N do
                    fast_subscrs( n, sysstring )
                endfor;
                if dup() == `\n` then
                    erase()
                endif;
            |#)
        endif
    endprocedure;
enddefine;

endsection;
