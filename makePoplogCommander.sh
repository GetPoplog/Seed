#!/bin/sh
# This is a script that will output the C source for a poplog-shell 
# program.

cat << \****
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <regex.h>

void printUsage( int argc, char * const argv[] ) {
****

( sed -e 's/"/\\"/g' | sed -e 's/.*/    puts( "&" );/') << \****
Usage: poplog [command-word] [options] [file(s)]

This poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'command-word'
determines what command is actually invoked.

INTERPRETER COMMANDS

poplog (pop11|prolog|clisp|pml) [options]
poplog (pop11|prolog|clisp|pml) [options] [file]
poplog (pop11|prolog|clisp|pml) [options] :[expression]
poplog (pop11|prolog|clisp|pml) [options] [vedcommand] [files]...

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

    4. When a vedcommand argument is supplied it causes Poplog to go straight
    into the editor (Ved) and can be any of the following: ved, im, help, ref,
    teach. For example:

        % poplog clisp im  # Starts Poplog's immediate mode in Common Lisp.


POP-11 SHORTHAND COMMANDS

poplog [options]
    Starts up in Pop-11. Same as: poplog pop11

poplog [options] ved [files]
    Opens the listed files in the editor. Same as: poplog [options] pop11 ved [files]

poplog [options] xved [files]
    Opens the listed files in the X-Windows editor (XVed).
    Same as: poplog [options] pop11 xved [files]

poplog [options] im [file]
    Open an immediate mode window on the file, if supplied, or a temporary
    file. Same as: poplog [options] pop11 im [file]

poplog [options] (help|teach|doc|ref) [topic]
    Searches for the named topic using the relevant documentation sections.
    If found opens a buffer in the editor and otherwise drops into a REPL.


UTILITY COMMANDS

poplog --help
    A special case that shows this usage information.

poplog exec [program] [arguments]
    Runs an arbitrary program in the Poplog environment i.e. with the special
    environment variables and $PATH set up. A typical use of this is

        % poplog exec bash      # Enter a shell to check the $PATH
        > which mkflavours
        /usr/local/poplog/current_usepop/pop/com/mkflavours


COMPILING AND LINKING WITH POPC

poplog popc [options] [file]
poplog poplink [options-and-files]
poplog poplibr [option] [w-library] [w-files]
    Runs the specialised compiler and linking commands. See the in-editor
    help on these commands.

        % poplog help popc

****


cat << \****
}

const char * const USEPOP = "[//USEPOP//]";

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

void setEnvReplacingUSEPOP( char * name, char * value, char * base ) {
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

    setenv( name, rhs, 1 );
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

int main( int argc, char *const argv[] ) {
    char * base = selfHome();
    if ( base == NULL ) {
        fprintf( stderr, "Cannot locate the Poplog home directory" );
        exit( EXIT_FAILURE );
    }
    truncatePopCom( base );
****
echo

CODE1=`env -i sh -c '(usepop="_build/poplog_base" && . $usepop/pop/com/popenv.sh && env)' | sort \
| grep -v '^\(_\|SHLVL\|PWD\|poplib\)=' \
| sed -e 's!_build/poplog_base![//USEPOP//]!g' \
| sed -e 's/"/\\"/g' \
| sed -e 's/\([^=]*\)=\(.*\)/    setEnvReplacingUSEPOP( "\1", "\2", base );/'`

CODE2=`env -i sh -c '(usepop="_build/poplog_base/pop/.." && . $usepop/pop/com/popenv.sh && env)' | sort \
| grep -v '^\(_\|SHLVL\|PWD\|poplib\)=' \
| sed -e 's!_build/poplog_base/pop/..![//USEPOP//]!g' \
| sed -e 's/"/\\"/g' \
| sed -e 's/\([^=]*\)=\(.*\)/    setEnvReplacingUSEPOP( "\1", "\2", base );/'`

if [ "$CODE1" != "$CODE2" ]; then
    exit 1
fi

echo "$CODE1"
echo 

# Note that poplib needs special handling. The algorithm used in $popcom/popenv.sh
# is to set poplib if not already defined to $HOME. It's unclear that this is a
# good idea.

cat << \****
    {
        char * home = getenv( "HOME" );
        if ( home != NULL ) {
            const char * const folder = ".poplog";
            char * path = malloc( strlen( home ) + 1 + strlen( folder ) + 1 );
            char * p = stpcpy( path, home );
            p = stpcpy( p, "/" );
            p = stpcpy( p, folder );
            setenv( "poplib", path, 0 );
        }
    }
****
echo 

cat << \****
    extendPath( getenv( "popsys" ), getenv( "PATH" ), getenv( "popcom" ) );

    if ( 0 ) {
        printf( "argc = %d\n", argc );
        for ( int i = 0; i < argc; i++ ) {
            printf( "argv[%d] = %s\n", i, argv[i] );
        }
    } else {
        if ( argc <= 1 ) {
            char *const pop11_args[] = { "pop11", NULL };
            execvp( "pop11", pop11_args );
        } else if ( 
            0
****

for i in basepop11 pop11 prolog clisp pml popc poplibr poplink
do
echo '            || strcmp( "'$i'", argv[1] ) == 0'
done

cat << \****
        ) {
            execvp( argv[1], &argv[1] );
        } else if (
            0
****

for i in ved im 'help' teach doc ref
do
echo '            || strcmp( "'$i'", argv[1] ) == 0'
done

cat << \****
        ) {
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
        } else if ( strcmp( "exec", argv[1] ) == 0 ) {
            execvp( argv[2], &argv[2] );
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
****
