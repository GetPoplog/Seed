# Contents of the docker folder

This folder is intended to house any files that are connected to using
docker containers with Poplog.

 * poplog_seccomp.json - a docker security profile to be used when running Poplog inside a Docker container.
 * seccomp.py - a Python script for updating a Poplog-friendly docker default [security profile](https://docs.docker.com/engine/security/seccomp/).
 