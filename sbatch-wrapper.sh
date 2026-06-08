#!/bin/bash
SHORTCOMMIT=`echo $COMMIT | cut -c 1-6`
sbatch -o "run-logs/slurm-%j.out" -J "$BRANCH-$SHORTCOMMIT --time=60 "$@" | cut -d " " -f 4
