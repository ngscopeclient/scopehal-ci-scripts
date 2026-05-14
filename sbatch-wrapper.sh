#!/bin/bash
sbatch -o "run-logs/slurm-%j.out" --time=120 "$@" | cut -d " " -f 4
