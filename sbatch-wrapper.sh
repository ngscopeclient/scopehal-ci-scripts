#!/bin/bash
sbatch -o "run-logs/slurm-%j.out" --time=45 "$@" | cut -d " " -f 4
