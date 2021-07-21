#!/bin/sh
# This is a script that will output the C source for a poplog-shell 
# program. Sections of C-code and shell script are interleaved which
# makes it harder to pick out comments - so a more emphatic style is
# used.

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

//  Bit-flags.
#define RUN_INIT_P          1
#define INHERIT_ENV         2
//  Bit-flag sets.
#define PREFER_SECURITY     0
#define PREFER_FLEXIBILITY  (RUN_INIT_P|INHERIT_ENV)


///////////////////////////////////////////////////////////////////////////////
//  Library routines: 
//      Mishap, an error reporting function
//      Chain, a 1D vector
///////////////////////////////////////////////////////////////////////////////


//  Mishap - Error reporting using printf-like functionality.

void mishap( const char *msg, ... ) {
    va_list args;
    va_start( args, msg );
    fprintf( stderr, "Mishap: " );
    vfprintf( stderr, msg, args );
    fprintf( stderr, "\n" );
    va_end( args );
    exit( EXIT_FAILURE );
}

//  Chains - 1D vectors.

typedef struct Chain * Chain;
typedef void * Ref;

enum {
    BUMP = 16
};

struct Chain {
    int     size;
    int     used;
    Ref     *data;
};

// Ensure there is room for at least n more bytes
// in the chain's buffer.
//
static Chain bump( Chain r, int n ) {
    int size = r->size;
    int used = r->used;
    int newused = used + n;

    if ( newused > size ) {
        //  We must realloc - and We need the new size to be at least this.
        int newsize = newused;

        //  But we want to grow by a factor to stop repeated linear
        //  extensions becoming O(N^2). We use a factor of 1.5.
        int delta = ( r-> size ) >> 2;
        //  And we want to skip the initial slow growth when we are
        //  just repeatedly extending the chain by 1 extra item. The value
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

Chain chain_push( Chain r, Ref ch ) {
    bump( r, 1 );
    r->data[ r->used ] = ch;
    r->used += 1;
    return r;
}

Chain chain_new() {
    // calloc implicitly zeros size & used & sets data to NULL.
    return (Chain)calloc( sizeof( struct Chain ), 1 );
}

void chain_free( Chain r ) {
    free( r->data );
    free( r );
}

int chain_length( Chain r ) {
    return r->used;
}

Ref chain_index( Chain r, int n ) {
    if ( !( 0 <= n && n < r->used ) ) {
        mishap( "Chain index (%d) out of range (0-%d)", n, r->used );
    }
    return r->data[ n ];
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
void printUsage( int argc, char * const argv[] ) {
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

    These interpreter commands have four different argument-patterns:

    1. If no other arguments are given, this will start a read-eval-print loop
    (REPL) in the specified language.

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


RESTRICTED AND UNRESTRICTED MODE

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


UTILITY ACTIONS

poplog --help
    A special case that shows this usage information.

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

//	http://sourceforge.net/p/predef/wiki/OperatingSystems/
// 
//	Type	Macro	Description
//	Identification	macintosh	Mac OS 9
//	Identification	Macintosh	Mac OS 9
//	Identification	__APPLE__ && __MACH__	Mac OS X

#ifdef __APPLE__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <libproc.h>
#include <unistd.h>

char * selfHome() {
    static char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
    const pid_t pid = getpid();
    const int ret = proc_pidpath( pid, pathbuf, sizeof pathbuf );
    if ( ret <= 0 ) {
    	return NULL;
    } else {
    	//	Replace the trailing '/' with a null.
    	char * s = strrchr( pathbuf, '/' );
    	if ( s != NULL ) {
    		*s = '\0';
    		return pathbuf;
    	} else {
            return NULL;
    	}
    }
}

#elif __linux__

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

#else

static_assert( false, "Not defined for operating systems other than Darwin nor Linux." );

#endif

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
    const char * const required_suffix = "/pop/pop";
    size_t len = strlen( base );
    if ( strcmp( required_suffix, &base[ len - 8 ] ) == 0 ) {
        base[ len - strlen( required_suffix ) ] = '\0';
    } else {
        fprintf( stderr, "Poplog installation folder missing $popsys folder\n" );
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
    char * rhs = malloc( len_needed );
    if ( rhs == NULL ) {
        fprintf( stderr, "Malloc failed\n" );
        exit( EXIT_FAILURE );
    }
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

    char * buff = malloc( strlen( prefix ) + 1 + strlen( path ) + 1 + strlen( suffix ) + 1 );
    if ( buff == NULL ) {
        fprintf( stderr, "Cannot extend $PATH, malloc failed\n" );
        exit( EXIT_FAILURE );
    }
    char * d = stpcpy( buff, prefix );
    d = stpcpy( d, ":" );
    d = stpcpy( d, path );
    d = stpcpy( d, ":" );
    strcpy( d, suffix );

    setenv( "PATH", buff, 1 );

    free( buff );
}

void setUpEnvironment( char * base, int flags, Chain envv ) {
    bool inherit_env = ( flags && INHERIT_ENV ) != 0;
    bool run_init_p = ( flags && RUN_INIT_P ) != 0;

    setenv( "usepop", base, !inherit_env );
****
echo

################################################################################
# We now run the popenv.sh script inside a clean environment to capture the 
# set of environment variables needed. We then need to replace any matches
# of the string "_build/poplog_base" ($usepop) with our unique value USEPOP.
# This will allow us to dynamically substitute with the selfHome'd value
# at run-time. 
#
# This is inherently a weak strategy because it relies on being able to 
# identify substitutions of $usepop. We improve its robustness by doing the
# process twice with different values of $usepop - using the '..' trick.
# If the resultant code is not identical we have a problem and we halt.
# (N.B It is probably not necessary to run the variables through sort but I 
# couldn't find a clear guarantee that env generates a sorted list.)
################################################################################

CODE1=`env -i sh -c '(usepop="_build/poplog_base" && . $usepop/pop/com/popenv.sh && env)' | sort \
| grep -v '^\(_\|SHLVL\|PWD\|poplib\|poplocal\(auto\|bin\)\?\)=' \
| sed -e 's!_build/poplog_base![//USEPOP//]!g' \
| sed -e 's/"/\\"/g' \
| sed -e 's/\([^=]*\)=\(.*\)/    setEnvReplacingUSEPOP( "\1", "\2", base, inherit_env );/'`

CODE2=`env -i sh -c '(usepop="_build/poplog_base/pop/.." && . $usepop/pop/com/popenv.sh && env)' | sort \
| grep -v '^\(_\|SHLVL\|PWD\|poplib\|poplocal\(auto\|bin\)\?\)=' \
| sed -e 's!_build/poplog_base/pop/..![//USEPOP//]!g' \
| sed -e 's/"/\\"/g' \
| sed -e 's/\([^=]*\)=\(.*\)/    setEnvReplacingUSEPOP( "\1", "\2", base, inherit_env );/'`

if [ "$CODE1" != "$CODE2" ]; then
    exit 1
fi

echo "$CODE1"
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
            char * path = malloc( strlen( home ) + 1 + strlen( folder ) + 1 );
            char * p = stpcpy( path, home );
            p = stpcpy( p, "/" );
            p = stpcpy( p, folder );
            setenv( "poplib", path, !inherit_env );
        }
    } else {
        // Point to a specially constructed 'empty init files' folder.
        const char * const subpath = "/pop/com/noinit" ;
        char * path = malloc( strlen( base ) + strlen( subpath ) + 1 );
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

    int n = chain_length( envv );
    for ( int i = 0; i < n; i++ ) {
        putenv( chain_index( envv, i ) );
    }
}

****

################################################################################
# Here we handle the options that it was invoked with. The overwrite parameter
# is passed to setUpEnvironment.
################################################################################

cat << \****
int processOptions( int argc, char *const argv[], char *base, int flags, Chain envv ) {
    if ( 0 ) {
        printf( "argc = %d\n", argc );
        for ( int i = 0; i < argc; i++ ) {
            printf( "argv[%d] = %s\n", i, argv[i] );
        }
    } else {
        if ( argc <= 1 ) {
            setUpEnvironment( base, flags, envv );
            char *const pop11_args[] = { "pop11", NULL };
            execvp( "pop11", pop11_args );
        } else if ( 
            0
****

# Interpreter and tools that simply need to be run as-is.
for i in basepop11 pop11 prolog clisp pml popc poplibr poplink ved xved
do
echo '            || strcmp( "'$i'", argv[1] ) == 0'
done

cat << \****
        ) {
            setUpEnvironment( base, flags, envv );
            execvp( argv[1], &argv[1] );
        } else if (
            0
****

# Implied pop11 commands N.B. 'ved' appears here as well but not xved.
for i in ved im 'help' teach doc ref
do
echo '            || strcmp( "'$i'", argv[1] ) == 0'
done

cat << \****
        ) {
            setUpEnvironment( base, flags, envv );
            char ** pop11_args = calloc( argc + 1, sizeof( char *const ) );
            pop11_args[ 0 ] = "pop11";
            for ( int i = 1; i < argc; i++ ) {
                pop11_args[ i ] = argv[ i ];
            }
            pop11_args[ argc ] = NULL; 
            execvp( "pop11", pop11_args );
        } else if ( strcmp( "--help", argv[1] ) == 0 ) {
            printUsage( argc - 2, &argv[2] );
            return EXIT_SUCCESS;
        } else if ( strcmp( "--help", argv[1] ) == 0 ) {
****

echo '            printf( "Poplog command tool: version '${GET_POPLOG_VERSION:-Undefined}'" );'
echo '            printf( "Compiled against base Poplog system: version '${POPLOG_VERSION:-Undefined}'" );'

cat << \****
            return EXIT_SUCCESS;
        } else if ( strcmp( "--run", argv[1] ) == 0 ) {
            return processOptions( argc - 1, &argv[1], base, PREFER_SECURITY, envv );
        } else if ( strcmp( "--dev", argv[1] ) == 0 ) {
            //  We want to force overwrites.
            return processOptions( argc - 1, &argv[1], base, PREFER_FLEXIBILITY, envv );
        } else if ( strcmp( "exec", argv[1] ) == 0 ) {
            if ( argc >= 3 ) {
                setUpEnvironment( base, flags, envv );
                execvp( argv[2], &argv[2] );
            } else {
                fprintf( stderr, "Too few arguments for exec action\n" );
                return EXIT_FAILURE;
            }
        } else if ( strcmp( "shell", argv[1] ) == 0 ) {
            char * shell_path = getenv( "SHELL" );
            if ( shell_path == NULL ) {
                fprintf( stderr, "$SHELL not defined\n" );
                return EXIT_FAILURE;
            } else {
                setUpEnvironment( base, flags, envv );
                char ** shell_args = calloc( argc, sizeof( char *const ) );
                shell_args[ 0 ] = shell_path;
                for ( int i = 2; i < argc; i++ ) {
                    shell_args[ i -  1 ] = argv[ i ];
                }
                shell_args[ argc - 1 ] = NULL; 
                execvp( shell_path, shell_args );
            }
        } else if ( strchr( argv[1], '=' ) != NULL ) {
            //  If there is an '=' sign in the argument it is an environment variable.
            chain_push( envv, argv[1] );
            return processOptions( argc - 1, &argv[1], base, flags, envv );
        } else {
            fprintf( stderr, "Unexpected arguments:" );
            for ( int i = 1; i < argc; i++ ) {
                fprintf( stderr, " %s", argv[ i ] );
            }
            fprintf( stderr, "\n" );
            return EXIT_FAILURE;
        }
    }
    perror( NULL );
    return EXIT_FAILURE;
}

int main( int argc, char *const argv[] ) {
    char * base = selfHome();
    if ( base == NULL ) {
        fprintf( stderr, "Cannot locate the Poplog home directory" );
        exit( EXIT_FAILURE );
    }

    Chain envv = chain_new();

    truncatePopCom( base );
    return processOptions( argc, argv, base, PREFER_FLEXIBILITY, envv );
}
****
