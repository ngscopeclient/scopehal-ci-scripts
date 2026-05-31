#!/bin/bash

# This script has to run as the "ci" user not www-data in order to ssh to builder nodes
# (so www-data needs permissions to sudo to ci to run this specific script)
cd /home/ci
export PATH=/usr/local/bin:/usr/bin:/bin:/home/ci/scopehal-ci-scripts/vm:/home/ci/scopehal-ci-scripts

# We are probably not a login shell (i.e. not executing .bashrc),
# so we need to add the internal root CA to the trusted list.
# Otherwise xo-cli will fail to connect to the XAPI and not be ale to start/stop/reset VMs
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/antikernel-root-2026.crt

########################################################################################################################
# Build and run tests using GPUs
# Submits are grouped in blocks of up to 3, one per GPU, for clarity but are scheduled by SLURM
# so jobs from a future block can begin running once the job on their GPU from the previous block completes,
# without any need to wait for other jobs in the block

JOB0=`sbatch-wrapper.sh -L nvidia1630_18:1,sanquentin:1 -p win11 run-task-msys job-windows.sh`
JOB1=`sbatch-wrapper.sh -L nvidia3050_51:1,sanquentin:1 -p debian-oldstable run-task job-debian.sh`
JOB2=`sbatch-wrapper.sh -L nvidia3050_8a:1,sanquentin:1 -p ubuntu-oldlts run-task job-ubuntu.sh`

##
JOB3=`sbatch-wrapper.sh -L nvidia3050_51:1,sanquentin:1 -p arch run-task job-arch.sh`
JOB4=`sbatch-wrapper.sh -L nvidia3050_8a:1,sanquentin:1 -p debian-stable run-task job-debian.sh`

########################################################################################################################
# Build and run tests with no GPU
# These still request the "sanquentin" license so we can manage oversubscription of vCPUs on the server

JOB5=`sbatch-wrapper.sh -L sanquentin:1 -p ubuntu-lts run-task job-ubuntu.sh`
JOB6=`sbatch-wrapper.sh -L sanquentin:1 -p fedora run-task job-fedora.sh`

# Sanitizer and analyzer jobs don't upload artifacts
# So we don't need to save the job IDs or delay postprocessing
sbatch-wrapper.sh -L sanquentin:1 -p ubuntu-lts run-task job-ubuntu-sanitizer.sh 2>&1
sbatch-wrapper.sh -L sanquentin:1 -p ubuntu-lts run-task job-ubuntu-analyze.sh 2>&1

########################################################################################################################
# Build and run tests that execute on the Mac Mini
# These request the "macmini" license so we can limit the number of jobs on the host,
# which has both a hypervisor-enforced 2-instance license limit, and only 16GB of RAM

JOB7=`sbatch-wrapper.sh -L macmini:1 -p macos run-task-macos job-macos.sh`
JOB8=`sbatch-wrapper.sh -L macmini:1 -p macos run-task job-debian.sh`

########################################################################################################################
# When all jobs that can generate artifacts have finished, run a job that processes their results

# This job uses negligible CPU so while it runs on sanquentin doesn't request a vCPU license
sbatch-wrapper.sh \
	-p postprocess \
	--dependency=$JOB0,$JOB1,$JOB2,$JOB3,$JOB4,$JOB5,$JOB6,$JOB7,$JOB8 \
	/home/ci/scopehal-ci-scripts/postprocess.sh $JOB0 $JOB1 $JOB2 $JOB3 $JOB4 $JOB5 $JOB6 $JOB7 $JOB8
