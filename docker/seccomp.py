#!/usr/bin/python3

import json
import sys
import argparse
from pathlib import Path

ADDR_NO_RANDOMIZE = 0x0040000
READ_IMPLIES_EXEC = 0x0400000

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
        for value in [ ADDR_NO_RANDOMIZE, READ_IMPLIES_EXEC, (ADDR_NO_RANDOMIZE|READ_IMPLIES_EXEC) ]
    )

parser = argparse.ArgumentParser(description="Modify default docker seccomp profile to allow syscalls needed by poplog")
parser.add_argument("--docker_seccomp_json", type=Path, help="Path to docker's default seccomp profile")

def main(argv):
    args = parser.parse_args(argv)
    jdata = loadDefault(args.docker_seccomp_json)
    inPlaceTransform(jdata)
    json.dump(jdata, sys.stdout, indent=4)
    print()

if __name__ == '__main__':
    main(sys.argv[1:])
