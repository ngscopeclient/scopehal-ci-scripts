#!/bin/sh
sbatch -p debian-stable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -p debian-oldstable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -p ubuntu-oldlts run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
