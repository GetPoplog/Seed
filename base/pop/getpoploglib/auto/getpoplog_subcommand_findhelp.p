compile_mode :pop11 +strict;

/*  Generates a JSON dump of where help can be located in the Poplog file
    hierarchy. The JSON obeys the following schema:
        https://gist.github.com/sfkleach/4065ef69d393c659e297420ebc8c0248
*/

section;

uses getpoplog;
uses dict;

/*
Design note:
- For exact matches use syssearchpath e.g. syssearchpath( [vedhelplist], 'rev' )
- For approximate matches use ved_??_search_doc_index e.g. ved_??_search_doc_index( 'rev', [vedhelplist] )
*/


define lconstant getline( path, line_no );
    lvars lines = pdtolist( discinline( path ) );
    return( lines( line_no ) );
enddefine;

define lconstant new_line_fetcher();
    newanyproperty(
        [], 8, 1, 7,
        syshash, nonop =, "perm",
        false,
        procedure( path, self );
            if sysisdirectory( path ) then
                []
            else
                pdtolist( discinline( path ) ) 
            endif ->> self( path )
        endprocedure
    );
enddefine;

define lconstant trim_summary( lines, from_lineno, to_lineno );

    define lconstant trim( line ) -> line;
        lvars i = locchar(`[`, 2, line);
        if i then
            skipchar_back(`\s`, i - 1, line) -> i;
            substring(1, i, line) -> line
        endif;
    enddefine;

    allbutfirst( from_lineno - 1, lines ) -> lines;
    [%
        repeat to_lineno - from_lineno + 1 times
            trim( lines.dest -> lines )
        endrepeat
    %]
enddefine;

lconstant
    CATEGORY_MISMATCH_PENALTY = 0.03,
    TOPIC_SUFFIX_MISMATCH_PENALTY = 0.04,
    TOPIC_PREFIX_MISMATCH_PENALTY = 0.05;

define constant category_match_quality( expected, actual );
    ;;; By coincidence the difference in length of names gives
    ;;; a good heuristic! (That ref and teach are extra-different).
    if expected == actual then
        1.0
    else
        lvars n = abs( datalength( expected ) - datalength( actual ) );
        (1.0 - CATEGORY_MISMATCH_PENALTY) ** n
    endif
enddefine;

define lconstant topic_match_quality( expected, actual );
    if expected == actual then
        1.0
    else
        lvars n = issubstring( expected, actual );
        if n then
            lvars n1 = n - 1;
            lvars pm = ( 1.0 - TOPIC_PREFIX_MISMATCH_PENALTY ) ** n1;
            lvars n2 = datalength( actual ) - ( n1 + datalength( expected ) );
            lvars sm = ( 1.0 - TOPIC_SUFFIX_MISMATCH_PENALTY ) ** n2;
            pm * sm
        else
            ;;; Not supposed to happen!
            0.0
        endif
    endif
enddefine;

define lconstant extend_with_content( option, procedure fetcher );
    lvars path = option("path");
    lvars content = (
        if option("from").isinteger and option("to").isinteger then
            lvars lines = fetcher( sysfileok( path ) );
            repeat option("from") - 1 times
                lines.tl -> lines
            endrepeat;
            [%
                lvars i;
                for i from option("from") to option("to") do
                    lines.dest -> lines
                endfor;
            %]
        else
            fetcher( sysfileok( path ) )
        endif
    );
    extend_dict( "content", content, option )
enddefine;

define subcmd_findhelp( category, topic, exact, with_content, maxmatches );
    lvars search_list = (
        if category == "help" then
            [vedhelplist]
        elseif category == "teach" then
            [vedteachlist]
        elseif category == "doc" then
            [veddoclist]
        elseif category == "ref" then
            [vedreflist]
        else
            [vedreflist]
        endif
    );

    lvars exact_match =
        lblock
            lvars m = syssearchpath( search_list, topic );
            if m.isstring then
                [ ^m help ] -> m
            endif;
            if m then
                lvars qc = category_match_quality( category, m(2) );
                ${ quality=qc, category=m(2), title=topic, path=m(1), from=pop_undef, to=pop_undef, summary=pop_undef }
            else
                false
            endif
        endlblock;

    lvars procedure fetcher = new_line_fetcher();
    lvars ecat = exact_match and exact_match("category");
    lvars etopic = exact_match and exact_match("title");
    lvars epath = exact_match and exact_match("path");
    lvars options = [%
        lvars topic_pattern = exact_match and topic or ( '*' <> topic <> '*' );
        lvars row;
        for row in ved_??_search_doc_index( topic_pattern, search_list ) do
            lvars result;
            for result in tl( row ) do
                lvars icat = hd( row );
                lvars ( itopic, apath, L1, L2, L3 ) = result.explode;
                lvars ipath = sysfileok( apath );
                if ipath = epath and icat == ecat and itopic = etopic then
                    ;;; Supersedes exact_match.
                    false -> exact_match
                endif;
                lvars lines = fetcher( ipath );
                lvars isummary = trim_summary( lines, L1, L2 );
                lvars qc = category_match_quality( category, icat );
                lvars qt = topic_match_quality( topic, itopic );
                ${ quality=qc*qt, category=icat, title=itopic, path=ipath, from=L1, to=L3, summary=isummary }
            endfor;
        endfor
    %];
    if exact_match then
        exact_match :: options -> options;
    endif;
    nc_listsort( options, procedure( x, y ); x("quality") >= y("quality") endprocedure ) -> options;
    if maxmatches and maxmatches > 0 and maxmatches < options.length then
        allfirst( maxmatches, options ) -> options;
    endif;
    if with_content then
        maplist( options, extend_with_content(%fetcher%) ) -> options
    endif;

    ${ popversion=popversion, documentation=options }
enddefine;

define getpoplog_subcommand_findhelp( options, args );
    dict_concat( ${ category='help', exact=false, content=false, maxmatches=false }, options ) -> options;
    json_println( 
        subcmd_findhelp( 
            consword(options("category")), 
            args(1), 
            options("exact"), 
            options("content"),
            strnumber( options("maxmatches") or '-1' )
        ) 
    )
enddefine;

endsection;
