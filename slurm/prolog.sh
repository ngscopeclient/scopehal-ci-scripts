#!/bin/sh
/usr/bin/sudo \
	--preserve-env=SLURM_JOB_NODELIST \
	--preserve-env=SLURM_NTASKS \
	--user=ci \
	/home/ci/scopehal-ci-scripts/vm/spawn-vm > /tmp/prolog.log 2>&1
