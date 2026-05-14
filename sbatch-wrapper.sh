#!/bin/bash
sbatch -o "run-logs/slurm-%j.out" --time=60 "$@" | cut -d " " -f 4
