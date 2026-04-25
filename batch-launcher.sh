#!/bin/sh

# Build and run tests with GPU
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630:1,nvidia1630_8a:1 \
	-p debian-stable \
	run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630:1,nvidia1630_51:1 \
	-p debian-oldstable \
	run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630:1,nvidia1630_18:1 \
	-p ubuntu-oldlts \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh

sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630:1,nvidia1630_18:1 \
	-p win11 \
	run-task-msys scopehal-ci-scripts/ci-jobs/job-windows.sh

# Build and run tests with no GPU
# These request the "nogpu" license so we can manage oversubscription
sbatch -o "run-logs/slurm-%j.out" \
	-L nogpu:1 \
	-p ubuntu-lts \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh
