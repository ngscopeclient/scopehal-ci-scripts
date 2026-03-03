# VM configuration scripts

This directory contains scripts for managing VMs that do the actual work

* get-snapshot-uuid: returns the UUID of the snapshot to revert to at the end of the job
* get-vm-uuid: returns the UUID of the VM to launch at the state of the job
* spawn-vm: start the VM named $SLURM_JOB_NODELIST (must be a single node job) and block until it's running

The VM's FQDN is implicitly $NODENAME.cidmz.poulsbo.antikernel.net, SLURM node naming must match DNS naming of the VM
