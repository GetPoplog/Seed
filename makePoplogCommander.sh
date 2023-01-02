#!/bin/bash
set -euo pipefail

# This is a script that will output the C source for a poplog-shell 
# program. Sections of C-code and shell script are interleaved which
# makes it harder to pick out comments - so a more emphatic style is
# used.

################################################################################
# We bundle the three build variants and defaults into some environment
# variables. DEFAULT_DEV_VARIANT is the right default for interactive work.
# DEFAULT_RUN_VARIANT is the default for scripts.
################################################################################

# The options are what the user types. They have to be translated into builds.
# e.g. --gui=xt has to become xt. The reason for that is that the 'editions'
# of Poplog relate to the mutually exclusive build options. The mapping is 
# implicitly defined by matching position in the two (congruent) arrays.
VARIANT_OPTIONS=(--no-gui --gui=xt --gui=motif)
VARIANT_BUILDS=(nox xt xm)
# Sanity check
[[ ${#VARIANT_OPTIONS[@]} -eq ${#VARIANT_BUILDS[@]} ]] || { echo "VARIANT_OPTIONS should have the same number of items as VARIANT_BUILDS but did not"; exit 1; }

# And the defaults are defined in terms of builds rather than options. That is
# because they are entirely internal constants.
DEFAULT_DEV_VARIANT=xm
DEFAULT_RUN_VARIANT=nox


################################################################################
# Refine the files containing env bindings for the 3 variants of Poplog.
# We start from nox-new, xt-new and xm-new, all inside _build/environments.
################################################################################

BUILD_HOME="$(pwd)/_build"

# In process_env we take lines of the form VAR=VALUE and escape the characters
# of the RHS using the conventions of the C-strings. 

# Note that we do not wish to capture the values of variables automatically
# introduced by running a shell SHLVL and PWD. Nor do we want to capture
# the folder location variables poplib, poplocalauto, poplocalbin. That is
# because GetPoplog has different defaults for those and the old values are
# irrelevant.

# N.B. It is in this function that we change from null-separated back to
# newline separated lines.

process_env() {
    build="$1"
    suffix="$2"
    env_file="${BUILD_HOME}/environments/${build}-base0${suffix}"
    [ -f "$env_file" ]
    sed -z -e 's/\\/\\\\/g' -e 's/\n/\\n/g' -e 's/"/\\"/g' \
    < "$env_file" | \
    tr '\0' '\n' | \
    grep -v '^\(_\|SHLVL\|PWD\|poplib\|poplocal\(auto\|bin\)\?\)=' | \
    sort
}

for build in "${VARIANT_BUILDS[@]}"
do
    process_env "$build" '' > "${BUILD_HOME}/environments/${build}-new"
    process_env "$build" '-cmp' > "${BUILD_HOME}/environments/${build}-new-cmp"
done 

# Verify that the base files are valid.
if ! ( cd _build/environments && cmp nox-new nox-new-cmp && cmp xt-new xt-new-cmp && cmp xm-new xm-new-cmp )
then
    echo "GetPoplog - cannot determine environment variables for Poplog" >&2
    exit 1
fi

# Find lines that are common to all three.
( cd _build/environments && \
    comm -12 nox-new xt-new | comm -12 - xm-new > shared.env \
)

# Remove common lines from each.
for build_type in "${VARIANT_BUILDS[@]}"
do 
    ( cd _build/environments && comm -23 "${build_type}-new" shared.env > "${build_type}.env" )
done


################################################################################
# Generate the header files for the commander-tool. Note how we use \**** as
# the Here Document marker. The backslash escapes the content so we don't have
# to worry about further escaping.
################################################################################

cat << \****
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <regex.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>
#include <limits.h>
#include <string.h>

// POSIX doesn't guarantee that <limits.h> will provide PATH_MAX if there
// aren't limits imposed by the OS.  In this case, the recommended approach is
// to use pathconf(3) with _PC_PATH_MAX to get the max limit but this is
// overkill.
#ifndef PATH_MAX
#define PATH_MAX            512  // 256 is the minimum required by POSIX.
#endif

//  Bit-flags.
#define RUN_INIT_P          0x1
#define INHERIT_ENV         0x2
#define VARIANT_X           0x4
#define VARIANT_MOTIF       0x8
//  Bit-flag sets for run vs dev.
#define RUN_FLAGS           0x3
#define PREFER_SECURITY     0x0
#define PREFER_FLEXIBILITY  (RUN_INIT_P|INHERIT_ENV)
//  Bit-flag sets for variants.
#define VARIANT_FLAGS       (VARIANT_X | VARIANT_MOTIF)
#define VARIANT_NOX         0x0
#define VARIANT_XT          (VARIANT_X)
#define VARIANT_XM          (VARIANT_X | VARIANT_MOTIF)
#define VARIANT_UNSET       (VARIANT_MOTIF)
#define INITIAL_FLAGS       (PREFER_FLEXIBILITY | VARIANT_UNSET)


///////////////////////////////////////////////////////////////////////////////
//  Library routines: 
//      startsWith, a predicate on strings
//      strEquals, another predicate on strings
//      mishap, an error reporting function
//      Vector, managed 1D vectors
//      Deque, managed double ended queue
///////////////////////////////////////////////////////////////////////////////

//  startsWith: does the subject start with prefix? ----------------------------
bool startsWith( const char * subject, const char * prefix ) {
    while ( *prefix ) {
        if ( *prefix++ != *subject++ ) return false;
    }
    return true;
}

//  strEquals: are two strings equal? ------------------------------------------
bool strEquals(const char * subject, const char * prefix ) {
    return strcmp( subject, prefix ) == 0;
}


//  Mishap - Error reporting using printf-like functionality. ------------------

// The msg is a printf like format-string, except that you do not have 
// to supply a \n, as that is automatically added for you.
void mishap( const char *msg, ... ) {
    va_list args;
    va_start( args, msg );
    fprintf( stderr, "Mishap: " );
    vfprintf( stderr, msg, args );
    fprintf( stderr, "\n" );
    va_end( args );
    exit( EXIT_FAILURE );
}


//  Ref, a synonym for void* ---------------------------------------------------

typedef void * Ref;

//  Vectors - managed 1D arrays ------------------------------------------------

typedef struct Vector * Vector;

enum {
    BUMP = 16
};

struct Vector {
    int     size;
    int     used;
    Ref     *data;
};

// Ensure there is room for at least n more bytes
// in the vector's buffer.
//
static Vector vector_bump( Vector r, int n ) {
    int size = r->size;
    int used = r->used;
    int newused = used + n;

    if ( newused > size ) {
        //  We must realloc - and We need the new size to be at least this.
        int newsize = newused;

        //  But we want to grow by a factor to stop repeated linear
        //  extensions becoming O(N^2). We use a factor of 1.5.
        int delta = ( r-> size ) >> 1;
        //  And we want to skip the initial slow growth when we are
        //  just repeatedly extending the vector by 1 extra item. The value
        //  is arbitrary but 8 or 16 are commonly used.
        if ( delta < BUMP ) {
            delta = BUMP;
        } 

        //  This ensures we have delta extra capacity before the next realloc.
        //  This delta is at least BUMP and at least half the previous capacity.
        newsize += delta; 
        
        r->data = (Ref *)realloc( r->data, newsize * sizeof( Ref ) );
        r->size = newsize;
    }
    return r;
}

void vector_push( Vector r, Ref ch ) {
    vector_bump( r, 1 );
    r->data[ r->used ] = ch;
    r->used += 1;
}

Vector vector_new() {
    // calloc implicitly zeros size & used & sets data to NULL.
    return (Vector)calloc( sizeof( struct Vector ), 1 );
}

void vector_free( Vector v ) {
    free( v->data );
    free( v );
}

int vector_length( Vector v ) {
    return v->used;
}

Ref vector_get( Vector r, int n ) {
    if ( !( 0 <= n && n < r->used ) ) {
        mishap( "Vector index (%d) out of range (0-%d)", n, r->used );
    }
    return r->data[ n ];
}

Ref vector_set( Vector r, int n, Ref x ) {
    if ( !( 0 <= n && n < r->used ) ) {
        mishap( "Vector index (%d) out of range (0-%d)", n, r->used );
    }
    return r->data[ n ] = x;
}

Ref * vector_as_array( Vector v ) {
    vector_bump( v, 1 );
    v->data[ v->used ] = NULL;
    return v->data;
}

void vector_insert_n( Vector v, int insertion_posn, int n_copies, Ref r ) {
    int Lv = vector_length( v );
    if ( 0 <= insertion_posn && insertion_posn <= Lv && n_copies >= 0 ) {
        vector_bump( v, n_copies );
        for ( int i = Lv - 1; i >= insertion_posn; i-- ) {
            v->data[ i + n_copies ] = v->data[ i ];
        }
        for ( int i = 0; i < n_copies; i++ ) {
            v->data[ insertion_posn + i ] = r;
        }
        v->used += n_copies;
    } else if ( n_copies < 0 ) {
        mishap( "Trying to insert a negative number of copies: %d", n_copies );
    } else {
        mishap( "Invalid insertion position: 0 <= %d && %d <= %d", insertion_posn, insertion_posn, vector_length( v ) );
    }
}


//  Deque - managed 1D arrays that support efficient insertion at front & back 

typedef struct Deque * Deque;

enum {
    DEQUE_BUMP = 16
};

struct Deque {
    int     offset;
    Vector  vector;
};

void deque_push_back( Deque d, Ref r ) {
    vector_push( d->vector, r );
}

void deque_push_front( Deque d, Ref r ) {
    if ( d->offset <= 0 ) {
        int delta = vector_length( d->vector ) >> 1;
        if ( delta < DEQUE_BUMP ) {
            delta = DEQUE_BUMP;
        }
        vector_insert_n( d->vector, 0, delta, NULL );
        d->offset = delta;
    }
    d->offset -= 1;
    vector_set( d->vector, d->offset, r );
}

Deque deque_new() {
    // calloc implicitly zeros offset.
    Deque d = (Deque)calloc( sizeof( struct Deque ), 1 );
    d->vector = vector_new();
    return d;
}

void deque_free( Deque d ) {
    vector_free( d-> vector );
    free( d );
}

int deque_length( Deque d ) {
    return vector_length( d->vector ) - d->offset;
}

Ref deque_get( Deque d, int n ) {
    int L = deque_length( d );
    if ( !( 0 <= n && n < L ) ) {
        mishap( "Deque index (%d) out of range (0-%d)", n, L );
    }
    return vector_get( d->vector, n + d->offset );
}

Ref deque_set( Deque d, int n, Ref r ) {
    int L = deque_length( d );
    if ( !( 0 <= n && n < L ) ) {
        mishap( "Deque index (%d) out of range (0-%d)", n, L );
    }
    return vector_set( d->vector, n + d->offset, r );
}

char * const * deque_as_array( Deque d ) {
    return (char * const *)( vector_as_array( d->vector ) + d->offset );
}

void deque_pop_front( Deque d ) {
    int L = vector_length( d->vector );
    if ( L >= 1 ) {
        d->offset += 1;
    } else {
        mishap( "Trying to pop from empty deque" );
    }
}

///////////////////////////////////////////////////////////////////////////////
//  End of library routines
///////////////////////////////////////////////////////////////////////////////


****

################################################################################
# Generate the printUsage function. This is essentially a list of calls to
# `puts` with constant strings. To make the content easier to work with we
# include it from a Here Document and transform it into the appropriate C
# calls using 'sed'.
################################################################################

cat << \****
void printUsage() {
****

( sed -e 's/"/\\"/g' | sed -e 's/.*/    puts( "&" );/') << \****
Usage: poplog [action-word] [options] [file(s)]

This poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'action-word'
determines what command is actually invoked.

INTERPRETER ACTIONS

poplog (pop11|prolog|clisp|pml) [OPTION]...
poplog (pop11|prolog|clisp|pml) [OPTION]... [FILE]
poplog (pop11|prolog|clisp|pml) [OPTION]... :[EXPRESSION]
poplog (pop11|prolog|clisp|pml) [OPTION]... [VEDCOMMAND] [FILE]...

    Poplog supports four different languages out of the box: Pop11,
    Prolog, Common Lisp and Standard ML specified by one of the
    commands pop11, prolog, clisp or pml respectively. All of these take
    options that control their start-up. Note that these options start
    with a '%' character.

     %x
     %x ( X Toolkit options )
        Initiates a connection with the X server by calling sysxsetup.
        You can supply standard X Toolkit options by placing them in
        parentheses after the %x.

     %noinit
        Suppresses compilation of the "init.p" file and any init files
        used by Ved or other subsystems.

     %nobanner
         Suppress printing of the Poplog banner.

    These interpreter commands (pop11, prolog, clisp, pml) have four different 
    argument-patterns:

    1. If no other arguments are given, this will start a read-eval-print loop
    (REPL) in the specified language. For example:

        % poplog pop11

        Sussex Poplog (Version 16.0001 Thu 12 Aug 00:47:01 BST 2021)
        Copyright (c) 1982-1999 University of Sussex. All rights reserved.

        Setpop
        : 


    2. If a file argument is given, this will start Poplog in the specified
    language, load and run the file and then exit. This implies --noinit.

    3. If a file-like argument starting with a ':' is found, it is treated as
    an expression, executed and then Poplog exits.

    4. When a VEDCOMMAND argument is supplied it causes Poplog to go straight
    into the editor (Ved) and can be any of the following: ved, im, help, ref,
    teach. For example:

        % poplog clisp im  # Starts Poplog's immediate mode in Common Lisp.


POP-11 SHORTHAND ACTIONS

poplog [OPTION]...
    Starts up in Pop-11. Same as: poplog pop11

poplog [OPTION]... ved [FILE]...
    Opens the listed files in the editor. Same as: 
    
        % poplog [OPTION]... pop11 ved [FILE]...

poplog [OPTION]... xved [FILE]...
    Opens the listed files in the X-Windows editor (XVed).
    Same as: 
    
        % poplog [OPTION]... pop11 xved [FILE]...

poplog [OPTION]... im [FILE]
    Open an immediate mode window on the FILE, if supplied, or a temporary
    file. Same as: 
    
        % poplog [OPTION]... pop11 im [FILE]

poplog [OPTION]... (help|teach|doc|ref) [TOPIC]
    Searches for the named TOPIC using the relevant documentation sections.
    If found opens a buffer in the editor and otherwise drops into a REPL.


MODES

poplog --run [OPTION]...
    This option forces the Poplog to use the pre-set defaults for all 
    environment variables and also to ignore $poplib. This makes it suitable
    for use in scripts, where the environment is standardised and per
    user customisation is not enabled. The remaining arguments are processed
    as usual.

poplog --dev [OPTION]...
    This option allows Poplog to inherit all existing special environment
    variables and runs the $poplib/init.p and $poplib/vedinit.p. This is the
    normal mode for programming in Poplog. It is not normally necessary to
    supply this option.

poplog --gui=(motif|xt) [OPTION]...
poplog --no-gui [OPTION]...
    Poplog can be used with an X-windows graphical user interface (GUI)
    or simply inside a terminal (`--no-gui`). The GUI look-and-feel can either 
    use the Motif toolkit (--gui=motif) or a much plainer X-toolkit style 
    (`--gui=xt`). This completely changes the appearance of VED, the built-in
    editor, for example.

    Because Poplog's saved-images are always made relative to a base 
    executable, experienced programmers do need to be aware that these options 
    select between different 'editions' of Poplog, which share the vast majority 
    of files but have their own $popsys folder, where their specialised 
    executables are kept.

    As a consequence, if you make a saved image with one 'edition' of Poplog
    you have to restore it with the same edition. 
    
    If neither `--gui` nor `--no-gui` are specified then the default depends 
    on whether poplog is being run interactively (--dev) or as a script (--run).
    In interactive mode, the environment variable $POPLOG_GUI_OPTION is checked, 
    which should have one of the options as its value: `--no-gui`, `--gui=xt` 
    or `--gui=motif`. Otherwise it falls back to `gui=motif`.

    When poplog is being run as a script (--run) then the default is `--no-gui`
    (run without X-windows).


UTILITY ACTIONS

poplog --help
    A special case that shows this usage information.

poplog --version
    Show version information for GetPoplog and the base Poplog system on 
    standard output and exits successfully.

poplog [NAME=VALUE]... [COMMAND [ARG]...]
    Adds/modifies environment variables in the Poplog environment for the
    duration of COMMAND and processes the remainder of the arguments normally. 
    Note: these bindings will correctly override the default bindings 
    established by the `--run` option. This is achieved by running them after
    the default bindings are set up.

poplog exec [PROGRAM] [ARG]...
    Runs an arbitrary program in the Poplog environment i.e. with the special
    environment variables and $PATH set up. A typical use of this is

        % poplog exec bash      # Enter a shell to check the $PATH
        > which mkflavours
        /usr/local/poplog/current_usepop/pop/com/mkflavours

poplog shell [OPTIONS] [FILE]
    Starts a shell in the Poplog environment. The $SHELL environment 
    variable is used to select the shell to be launched. Arguments are
    passed to the shell in the normal way.


COMPILING AND LINKING WITH POPC

poplog popc [OPTION]... [FILE]
poplog poplink [OPTION_OR_FILE]...
poplog poplibr [OPTION] [W-LIBRARY] [W-FILE]...
    Runs the specialised compiler and linking commands. See the in-editor
    help on these commands.

        % poplog help popc

****

cat << \****
}
****

################################################################################
# Now we have the selfHome function. I have included this from some of my
# own software and it retains the Darwin code as well as the linux code. 
# Arguably this should be removed but it serves as a guide for how to cope
# with different Unixes.
################################################################################

cat << \****

#include <stdio.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>

char * selfHome() {
    static char pathbuf[ PATH_MAX ];
    int count = readlink( "/proc/self/exe", pathbuf, sizeof pathbuf );
    if ( count >= 0 ) {
        pathbuf[ count ] = '\0';
		//	Replace the trailing '/' with a null.
    	char * s = strrchr( pathbuf, '/' );
    	if ( s != NULL ) {
    		*s = '\0';
    		return pathbuf;
    	} else {
            return NULL;
    	}
    } else {
    	return NULL;
    }
}
void * safe_malloc( size_t n ) {
    void * ptr = malloc( n );
    if ( ptr == NULL ) {
        perror( NULL );
        exit( EXIT_FAILURE );
    }
    return ptr;
}

void setEnvSpec( const char * envspec ) {
    // envspec is a string of the form "name=val"
    char * equalpos = strchr( envspec, '=' );
    if ( equalpos == NULL ) {
        fprintf( stderr, "Invalid environment variable spec %s, missing '='.\n", envspec );
        exit( EXIT_FAILURE );
    };

    size_t namelen = equalpos - envspec;
    char * name = safe_malloc( namelen + 1 );
    strncpy( name, envspec, namelen );
    name[namelen] = '\0';

    int vallen = strlen( envspec ) - ( namelen );
    char * val = safe_malloc( vallen + 1 );
    strncpy( val, equalpos + 1, vallen );
    val[vallen] = '\0';

    if ( setenv( name, val, 1 ) < 0) {
        fprintf( stderr, "Cannot set the environment variable %s\n", envspec );
        exit( EXIT_FAILURE );
    };
    // name and val could be freed here since setenv should copy its
    // arguments. Steve had observed that sometimes it didn't copy the
    // key value, so we don't free just in case.
}

****

################################################################################
# Now we have the main bulk of the code, Note that the
# USEPOP string is intended to be a distinctive value that will not occur as
# part of a normal filename.
################################################################################

cat << \****

#define USEPOP_LITERAL "[//USEPOP//]"

// Compile-time string concatenation using literals saves tedious string coding.
#define POPLOCAL_LITERAL USEPOP_LITERAL "/../../poplocal"

const char * const USEPOP = USEPOP_LITERAL;

void truncatePopCom( char * base ) {
    const char * const required_suffix = "/pop/bin";
    size_t len = strlen( base );
    if ( strcmp( required_suffix, &base[ len - 8 ] ) == 0 ) {
        base[ len - strlen( required_suffix ) ] = '\0';
    } else {
        fprintf( stderr, "Poplog installation folder missing $popsys folder\n" );
        fprintf( stderr, "Base folder is: %s\n", base );
        exit( EXIT_FAILURE );
    }
}

int howManyTimes( const char * haystack, const char * needle ) {
    int count = 0;
    const char * remaining_haystack = haystack;
    for (;;) {
        remaining_haystack = strstr( remaining_haystack, needle );
        if ( remaining_haystack == NULL ) break;
        remaining_haystack += strlen( needle );
        count += 1;
    }
    return count;
}

void setEnvReplacingUSEPOP( char * name, char * value, char * base, bool inherit_env ) {
    int count = howManyTimes( value, USEPOP );
    size_t len_needed = strlen( value ) + strlen( base ) * count + 1;
    char * rhs = safe_malloc( len_needed );
    rhs[ 0 ] = '\0';    //  Initialise as empty

    char * end_of_rhs = rhs;
    const char * haystack = value;
    for (;;) {
        const char * h = strstr( haystack, USEPOP );
        if ( h == NULL ) break;
        end_of_rhs = stpncpy( end_of_rhs, haystack, h - haystack );
        end_of_rhs = stpcpy( end_of_rhs, base );
        haystack = h + strlen( USEPOP );
    }
    strcpy( end_of_rhs, haystack );

    setenv( name, rhs, !inherit_env );
    free( rhs );
}

void extendPath( char * prefix, char * path, char * suffix ) {
    if ( prefix == NULL || path == NULL || suffix == NULL ) {
        fprintf( stderr, "Cannot extend $PATH: %s, %s, %s\n", prefix, path, suffix );
        exit( EXIT_FAILURE );
    }

    char * buff = safe_malloc( strlen( prefix ) + 1 + strlen( path ) + 1 + strlen( suffix ) + 1 );
    char * d = stpcpy( buff, prefix );
    d = stpcpy( d, ":" );
    d = stpcpy( d, path );
    d = stpcpy( d, ":" );
    strcpy( d, suffix );

    setenv( "PATH", buff, 1 );

    free( buff );
}

****

# Transform the VAR=VALUE shape into the final C-code.
env_file_to_c_code() {
    filename="$1"
    sed -e 's/\([^=]\+\)=\(.*\)/    setEnvReplacingUSEPOP( "\1", "\2", base, inherit_env );/' < "$filename"
}

# Here we create three functions for setting the environment variables that
# are unique to the build variants: nox, xm, xt. These will be called
# nox_setUpEnvVars, xm_setUpEnvVars, xt_setUpEnvVars.
for variant in "${VARIANT_BUILDS[@]}"
do
    echo "void ${variant}_setUpEnvVars( char * base, bool inherit_env ) {"
    env_file_to_c_code "_build/environments/${variant}.env"
    echo "}"
    echo
done

cat << \****
// This function will establish the environment variables for Poplog.
void setUpEnvironment( char * base, int flags, Vector envv ) {
    bool inherit_env = ( flags & INHERIT_ENV ) != 0;
    bool run_init_p = ( flags & RUN_INIT_P ) != 0;

    setenv( "usepop", base, !inherit_env );

    int vflags = flags & VARIANT_FLAGS;
    switch ( vflags ) {
****

for variant in "${VARIANT_BUILDS[@]}"
do
    echo "        case VARIANT_${variant^^}:"
    echo "            ${variant}_setUpEnvVars( base, inherit_env );"
    echo "            break;"
done

cat << ****
        default:
            if ( inherit_env ) {
                char * use_build = getenv( "POPLOG_GUI_OPTION" );
                if ( use_build == NULL ) {
                    use_build = "${DEFAULT_DEV_VARIANT}"; 
                }
                if ( 0 ) {
                    // Skip
****

for build in "${VARIANT_BUILDS[@]}"
do
    # shellcheck disable=SC2086
    echo '                } else if ( strEquals( "'$build'", use_build ) ) {'
    echo "                    ${build}_setUpEnvVars( base, inherit_env );"
done

cat << ****
                } else {
                    mishap( "POPLOG_GUI_OPTION is '%s' but must be one of: %s", use_build, "${VARIANT_OPTIONS[@]}" );
                }
            } else {
                ${DEFAULT_RUN_VARIANT}_setUpEnvVars( base, inherit_env );
            }
            break;
    }

****

# Now we squirt in the shared environment variables.
env_file_to_c_code "_build/environments/shared.env"
echo 

################################################################################
# Note that $poplocal needs special handling. The pre-existing defaults are
# problematic because they can leave $poplocal pointing to a read-only area.
# However, changing $poplocal's default also requires handling the dependent 
# variables $poplocalauto and $poplocalbin. See discussion here:
# https://github.com/GetPoplog/Seed/wiki/A-new-default-for-$poplocal
################################################################################

cat << \****
    setEnvReplacingUSEPOP( "poplocal", POPLOCAL_LITERAL, base, inherit_env );
    setEnvReplacingUSEPOP( "poplocalauto", POPLOCAL_LITERAL "/auto", base, inherit_env );
    setEnvReplacingUSEPOP( "poplocalbin", POPLOCAL_LITERAL "/psv", base, inherit_env );
****

################################################################################
# Note that poplib needs special handling. The algorithm used in $popcom/popenv.sh
# is to set poplib if not already defined to $HOME. Using $HOME for this is
# a bad idea and we depart from that by introducing a dot-folder ".poplog".
################################################################################

cat << \****
    if ( run_init_p ) {
        char * home = getenv( "HOME" );
        if ( home != NULL ) {
            const char * const folder = ".poplog";
            char * path = safe_malloc( strlen( home ) + 1 + strlen( folder ) + 1 );
            char * p = stpcpy( path, home );
            p = stpcpy( p, "/" );
            p = stpcpy( p, folder );
            setenv( "poplib", path, !inherit_env );
        }
    } else {
        // Point to a specially constructed 'empty init files' folder.
        const char * const subpath = "/pop/com/noinit" ;
        char * path = safe_malloc( strlen( base ) + strlen( subpath ) + 1 );
        char * p = stpcpy( path, base );
        p = stpcpy( p, subpath );
        setenv( "poplib", path, !inherit_env );
    }
****
echo 

################################################################################
# And now we handle the different cases of the Poplog commands. 
################################################################################

cat << \****
    extendPath( getenv( "popsys" ), getenv( "PATH" ), getenv( "popcom" ) );

    int n = vector_length( envv );
    for ( int i = 0; i < n; i++ ) {
        setEnvSpec( vector_get( envv, i ) );
    }
}

****


################################################################################
# Here we handle the options that it was invoked with. The overwrite parameter
# is passed to setUpEnvironment.
################################################################################

cat << \****
int processArgs( Deque argd, char * base, int flags, Vector envv ) {
    if ( deque_length( argd ) == 0 ) {
        setUpEnvironment( base, flags, envv );
        char * const pop11_args[] = { "pop11", NULL };
        execvp( "pop11", pop11_args );
    } 
    
    char * arg0 = deque_get( argd, 0 );
    if ( 
        0
****

# Interpreter and tools that simply need to be run as-is.
for i in basepop11 pop11 prolog clisp pml popc poplibr poplink ved xved
do
echo '        || strcmp( "'$i'", arg0 ) == 0'
done

cat << \****
    ) {
        setUpEnvironment( base, flags, envv );
        execvp( arg0, deque_as_array( argd ) );
    } else if (
        ( arg0[0] == ':' )    // :[EXPRESSION]
****

# Implied pop11 commands N.B. 'ved' appears here as well but not xved.
for i in ved im 'help' teach doc ref
do
echo '        || strcmp( "'$i'", arg0 ) == 0'
done

cat << \****
    ) {
        setUpEnvironment( base, flags, envv );
        deque_push_front( argd, "pop11" );
        execvp( "pop11", deque_as_array( argd ) );
    } else if ( startsWith( arg0, "--" ) ) {
        if ( strEquals( "--help", arg0 ) ) {
            printUsage();
            return EXIT_SUCCESS;
        } else if ( strEquals( "--version", arg0 ) ) {
            setUpEnvironment( base, flags, envv );
****

# shellcheck disable=SC2028
echo '            printf( "Poplog command tool v'"${GETPOPLOG_VERSION:-Undefined}"'\\n" );'

cat << \****

            execlp( "corepop", "corepop", "%nort", ":printf( pop_internal_version // 10000, 'Running base Poplog system %p.%p\\n' );", NULL );
            return EXIT_FAILURE; // Just in case the execlp fails.
        } else if ( strEquals( "--run", arg0 ) ) {
            flags = ( PREFER_SECURITY | ( flags & ~RUN_FLAGS ) );
            deque_pop_front( argd );
            return processArgs( argd, base, flags, envv );
        } else if ( strEquals( "--dev", arg0 ) ) {
            //  We want to force overwrites.
            flags = ( PREFER_FLEXIBILITY | ( flags & ~RUN_FLAGS ) );
            deque_pop_front( argd );
            return processArgs( argd, base, flags, envv );          
        } else if ( strEquals( arg0, "--no-gui" ) ) {
            flags = ( VARIANT_NOX | ( flags & ~VARIANT_FLAGS ) );
            deque_pop_front( argd );
            return processArgs( argd, base, flags, envv );
        } else if ( startsWith( arg0, "--gui=" ) ) {
            if ( 0 ) {
                // Never taken - a trick to regularise the following cases.
****
for ((n=0; n<${#VARIANT_OPTIONS[@]}; n++))
do
    option="${VARIANT_OPTIONS[n]}"
    build="${VARIANT_BUILDS[n]}"
    if [ "$build" != 'nox' ]; then
        echo "            } else if ( strEquals( arg0, \"${option}\" ) ) {"
        echo "                flags = ( VARIANT_${build^^} | ( flags & ~VARIANT_FLAGS ) );"
    fi
done
cat << \****
            } else {
                mishap( "Unrecognised GUI option: %s", arg0 );
            }
            deque_pop_front( argd );
            return processArgs( argd, base, flags, envv );
        } else {
            mishap( "Unrecognised --OPTION: %s", arg0 );
        }
    } else if ( strcmp( "exec", arg0 ) == 0 ) {
        if ( deque_length( argd ) >= 2 ) {
            deque_pop_front( argd );
            setUpEnvironment( base, flags, envv );
            execvp( deque_get( argd, 0 ), deque_as_array( argd ) );
        } else {
            fprintf( stderr, "Too few arguments for exec action\n" );
            return EXIT_FAILURE;
        }
    } else if ( strcmp( "shell", arg0 ) == 0 ) {
        char * shell_path = getenv( "SHELL" );
        if ( shell_path == NULL ) {
            fprintf( stderr, "$SHELL not defined\n" );
            return EXIT_FAILURE;
        } else {
            setUpEnvironment( base, flags, envv );
            deque_pop_front( argd );
            deque_push_front( argd, shell_path );
            execvp( shell_path, deque_as_array( argd ) );
        }
    } else if ( strchr( arg0, '=' ) != NULL ) {
        // If there is an '=' sign in the argument it is an environment variable.
        vector_push( envv, arg0 );
        deque_pop_front( argd );
        return processArgs( argd, base, flags, envv );
    } else {
        setUpEnvironment( base, flags, envv );
        char * subpath = "/pop/getpoploglib/lib/getpoplog_run_subcommand.p";
        char * path = safe_malloc( strlen( subpath ) + strlen( base ) + 1 );
        char * p = stpcpy( path, base );
        p = stpcpy( p, subpath );
        deque_push_front( argd, path );
        deque_push_front( argd, "pop11" );
        // If execvp is successful, pop11 will responsible for returning the correct error code. 
        execvp( "pop11", deque_as_array( argd ) );
    }
    // We only reach here if the execvp fails, which would be very unusual.
    perror( NULL );
    return EXIT_FAILURE;
}

int main( int argc, char * const argv[] ) {
    char * base = selfHome();
    if ( base == NULL ) {
        fprintf( stderr, "Cannot locate the Poplog home directory" );
        exit( EXIT_FAILURE );
    }

    Deque argd = deque_new();
    //  Skip the 0th argument.
    for ( int i = 1; i < argc; i++ ) {
        deque_push_back( argd, argv[i] );
    }

    Vector envv = vector_new();

    truncatePopCom( base );
    return processArgs( argd, base, INITIAL_FLAGS, envv );
}
****
