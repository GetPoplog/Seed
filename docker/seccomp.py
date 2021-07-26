#!/usr/bin/python3

import json
import sys

def loadDefault( filename ):
    with open( filename, 'r' ) as f:
        return json.load( f )

def inPlaceTransform( jdata ):
    jdata[ 'syscalls' ].extend(
        { 
            "names": [ "personality" ],
            "action": "SCMP_ACT_ALLOW",
            "args": [ { "index": 0, "value": value, "op": "SCMP_CMP_EQ" } ]
        }
        for value in [ 0x0040000, 0x0400000, 0x0440000 ]
    )

if __name__ == "__main__":
    jdata = loadDefault( sys.argv[1] )
    inPlaceTransform( jdata )
    json.dump( jdata, sys.stdout, indent=4 )
    print()
