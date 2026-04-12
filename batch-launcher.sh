#!/bin/sh
sbatch -L nvidia1630:1,nvidia1630_18:1 -p debian-stable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -L nvidia1630:1,nvidia1630_51:1 -p debian-oldstable run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -L nvidia1630:1,nvidia1630_18:1 -p ubuntu-oldlts run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
