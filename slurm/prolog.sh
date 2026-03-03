#!/bin/sh
echo "NODELIST=$SLURM_JOB_NODELIST NTASKS=$SLURM_NTASKS"
/usr/bin/sudo \
	--preserve-env=SLURM_JOB_NODELIST,SLURM_NTASKS \
	--user=ci \
	/home/ci/scopehal-ci-scripts/vm/spawn-vm > /tmp/prolog.log 2>&1
