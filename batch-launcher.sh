#!/bin/sh
sbatch -L nvidia1630:1,nvidia1630_8a:1 -p debian-stable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh -o "run-logs/slurm-%j.out"
sbatch -L nvidia1630:1,nvidia1630_51:1 -p debian-oldstable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh -o "run-logs/slurm-%j.out"
sbatch -L nvidia1630:1,nvidia1630_18:1 -p ubuntu-oldlts run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh -o "run-logs/slurm-%j.out"
sbatch                                 -p ubuntu-lts run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh -o "run-logs/slurm-%j.out"
