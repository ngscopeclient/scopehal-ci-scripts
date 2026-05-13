#!/bin/bash
cd /home/ci

########################################################################################################################
# Build and run tests using GPUs
# Submits are grouped in blocks of up to 3, one per GPU, for clarity but are scheduled by SLURM
# so jobs from a future block can begin running once the job on their GPU from the previous block completes,
# without any need to wait for other jobs in the block

sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630_18:1,sanquentin:1 \
	-p win11 \
	--time=45 \
	run-task-msys scopehal-ci-scripts/ci-jobs/job-windows.sh
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630_51:1,sanquentin:1 \
	-p debian-oldstable \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-debian.sh
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630_8a:1,sanquentin:1 \
	-p ubuntu-oldlts \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh

##

sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630_51:1,sanquentin:1 \
	-p arch \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-arch.sh
sbatch -o "run-logs/slurm-%j.out" \
	-L nvidia1630_8a:1,sanquentin:1 \
	-p debian-stable \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-debian.sh

########################################################################################################################
# Build and run tests with no GPU
# These still request the "sanquentin" license so we can manage oversubscription of vCPUs on the server

sbatch -o "run-logs/slurm-%j.out" \
	-L sanquentin:1 \
	-p ubuntu-lts \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu.sh

sbatch -o "run-logs/slurm-%j.out" \
	-L sanquentin:1 \
	-p ubuntu-lts \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu-sanitizer.sh

sbatch -o "run-logs/slurm-%j.out" \
	-L sanquentin:1 \
	-p ubuntu-lts \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-ubuntu-analyze.sh

sbatch -o "run-logs/slurm-%j.out" \
	-L sanquentin:1 \
	-p fedora \
	--time=45 \
	run-task scopehal-ci-scripts/ci-jobs/job-fedora.sh

########################################################################################################################
# Build and run tests that execute on the Mac Mini
# These request the "macmini" license so we can limit the number of jobs on the host,
# which has both a hypervisor-enforced 2-instance license limit, and only 16GB of RAM

sbatch -o "run-logs/slurm-%j.out" \
	-L macmini:1 \
	-p macos\
	--time=45 \
	run-task-macos scopehal-ci-scripts/ci-jobs/job-macos.sh
