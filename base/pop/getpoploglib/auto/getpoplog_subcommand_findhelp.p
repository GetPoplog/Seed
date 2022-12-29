compile_mode :pop11 +strict;

/*  Generates a JSON dump of where help can be located in the Poplog file
    hierarchy. The JSON obeys the following schema:

{
  "$id": "https://github.com/GetPoplog/findhelp.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "FindHelp",
  "type": "object",
  "properties": {
    "popversion": {
      "description": "A string describing the version of Poplog.",
      "type": "string"
    },
    "documentation": {
      "description": "Matching documentation.",
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "quality": {
            "description": "A number from 0 to 1.0 indicating the match quality, with 1 being a perfect match.",
            "type": "number"
          },
          "category": {
            "description": "The category of documentation, reflecting the level formality and technical detail.",
            "type": "string",
            "enum": [ "help", "teach", "doc", "ref" ]
          },
          "title": {
            "description": "The title of the resource.",
            "type": "string"
          },
          "summary": {
            "description": "An optional summary of the resource, which may be null.",
            "type": ["string", "null"]
          },
          "path": {
            "description": "File path of the resource.",
            "type": "string"
          },
          "lineno": {
            "description": "Position in the file the description starts, which may be null.",
            "type": ["integer", "null"]
          }
        },
        "required": ["quality", "title", "summary", "path", "lineno", "category"],
        "additionalProperties": false
      }
    },
    "required": ["popversion", "documentation"],
    "additionalProperties": false
  }
}

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
            pdtolist( discinline( path ) ) ->> self( path )
        endprocedure
    );
enddefine;

define lconstant trim_summary( line ) -> line;
    lvars i = locchar(`[`, 2, line);
    if i then
        skipchar_back(`\s`, i - 1, line) -> i;
        substring(1, i, line) -> line
    endif;
enddefine;

lconstant
    CATEGORY_MISMATCH_PENALTY = 0.03,
    TOPIC_SUFFIX_MISMATCH_PENALTY = 0.04,
    TOPIC_PREFIX_MISMATCH_PENALTY = 0.05;

define lconstant category_match_quality( expected, actual );
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

define subcmd_findhelp( category, topic, exact );
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
            if m then
                lvars qc = category_match_quality( category, m(2) );
                ${ quality=qc, category=m(2), title=topic, path=m(1), lineno=false, summary=false }
            else
                false
            endif
        endlblock;

    returnif( exact )( exact_match and [ ^exact_match ] or [] );

    lvars procedure fetcher = new_line_fetcher();
    lvars ecat = exact_match and exact_match("category");
    lvars etopic = exact_match and exact_match("title");
    lvars epath = exact_match and exact_match("path");
    lvars options = [%
        lvars row;
        for row in ved_??_search_doc_index( '*' <> topic <> '*', search_list ) do
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
                lvars isummary = trim_summary( lines( L1 ) );
                lvars qc = category_match_quality( category, icat );
                lvars qt = topic_match_quality( topic, itopic );
                ${ quality=qc*qt, category=icat, title=itopic, path=ipath, lineno=L1, summary=isummary }
            endfor;
        endfor
    %];
    if exact_match then
        exact_match :: options -> options;
    endif;
    nc_listsort( options, procedure( x, y ); x("quality") >= y("quality") endprocedure )
enddefine;

define getpoplog_subcommand_findhelp( options, args );
    dict_concat( ${ category='help', exact=false }, options ) -> options;
    json_println( subcmd_findhelp( consword(options("category")), args(1), options("exact") ) )
enddefine;

endsection;