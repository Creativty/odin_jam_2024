#!/usr/bin/env bash
ODIN_COMMAND="build"
if [[ "$1" == "run" ]]; then ODIN_COMMAND="run"; fi
odin $ODIN_COMMAND . -o:speed -out:dodge
