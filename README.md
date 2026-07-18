# scopehal-ci-scripts

Test scripts for continuous integration builds on our internal lab cluster, allowing hardware-in-loop testing.

azonenberg is the primary maintainer of the infrastructure but this README is provided for other project team members to understand the environment.

## Hardware setup

Since most runners have permanently-assigned PCIe passthrough GPUs, each runner is permanently assigned to one server and they cannot be dynamically scheduled.

We use SLURM's floating-license-pool system to limit oversubscription of compute resources (CPU/RAM) and provide mutual exclusion for PCIe passthrough devices that can be bound to one of several VMs, but not both. No actual FlexLM or similar licenses are in use, but this is the best means available in SLURM to arbitrate access to shared resources.

Each CI job **must** request all of the SLURM licenses listed in the table for the corresponding job partition **even if you do not intend to use the GPU or full RAM capacity** since the GPU and RAM will be bound to the runner regardless of whether you use it or not. Failure to request the correct license can result in stalls in which a runner VM (not necessarily the incorrectly licensed one) fails to start due to resource unavailability on the host. The SLURM job will stall waiting for the not-started runner to be reachable over SSH, until the timeout period elapses and the job is canceled.

### cheddar

This server is a Mac Mini with a 10-core Apple M4 CPU and 16GB of RAM.

| Hostname | SLURM partition | vCPUs | RAM (GB) | OS | GPU | SLURM licenses |
|----------|-----------------|-------|----------|----|-----|----------------|
| macos | macos | 8 | 8 | MacOS 15.6.1 | Apple M4 (PV) | macmini |
| debian-stable-aarch64 | macos | 8 | 8 | Debian 13 aarch64 | None | macmini |

### rikers

This server has an Intel Xeon Scalable Gold 5320 (26 physical / 52 logical cores), 128GB of RAM, and an NVIDIA GTX 1630 GPU which is currently allocated to a non-CI VM and not available for use by CI jobs.

* ubuntu-lts-\[1-3\]: Ubuntu 26.04, no GPU, 12 vCPU, 24GB RAM

### sanquentin

This server has a Xeon Platinum 8362 (32 physical / 64 logical cores), 512GB of RAM, and three NVIDIA RTX 3050 GPUs.

Available runners on this host are:
* arch: Arch (fully updated), NVIDIA RTX 3050, 8 vCPU, 32GB RAM
* debian-oldstable: Debian 12, NVIDIA RTX 3050, 8 vCPU, 32GB RAM
* debian-stable: Debian 13, NVIDIA RTX 3050, 8 vCPU, 32GB RAM
* fedora: Fedora 43, no GPU, 8 vCPU, 32GB RAM
* ubuntu-oldlts: Ubuntu 24.04, NVIDIA RTX 3050, 8 vCPU, 32GB RAM
* win11: Windows 11, NVIDIA RTX 3050, 8 vCPU, 32GB RAM

## Push hook

(describe how jobs come in)

## SLURM configuration

### Job scheduling

The CI orchestrator VM runs a local SLURM job scheduler instance with one slurmd per runner VM.

Jobs are submitted to the queue by `batch-launcher.sh`. Currently this is:
* One build-and-test cycle for each supported operating system
* One build-and-test cycle on Ubuntu LTS with asan and ubsan enabled
* cppcheck and clang-analyzer static analysis on Ubuntu LTS
* Tarball generation on debian-stable

Each job is submitted to a SLURM partition corresponding to the desired runner type. Partitions all have a single SLURM node in them, with the exception of ubuntu-lts which has two.

Jobs request one or more SLURM "licenses" to manage oversubscription, since SLURM is not natively aware of the fact that the virtual runners share CPU, RAM, and GPU resources on a physical virtualization host. These are not actual software licenses a la FlexLM, but provide a convenient form of mutexing without custom SLURM plugins.

The available licenses are:
* macmini: Jobs running on the Mac Mini
* nvidia3050_51: RTX 3050 6GB GPU at PCIe bus address 0x51
* nvidia3050_52: RTX 3050 GPU at PCIe bus address 0x52
* nvidia3050_8a: RTX 3050 6GB GPU at PCIe bus address 0x8a
* rikers: Jobs running on small xcp-ng server
* sanquentin: Jobs running on large xcp-ng server

Runner VMs with PCIe passthrough GPUs are statically bound to specific GPUs at configuration time; dynamic configuration is not supported. Any job on a runner that has an attached GPU must request the corresponding license to avoid resource conflicts, even if it does not intend to use the GPU, since no other runner is allowed to spawn attached to the same GPU until this runner terminates.

As of this writing, the mapping is:
* 0x51: ci-arch, ci-debian-oldstable
* 0x52: ci-win11
* 0x8a: ci-debian-stable, ci-ubuntu-oldlts
* All others: no passthrough GPU

To avoid overloading the VM server and causing poor performance for other workloads such as the CI dashboard and lab sandbox instances, all jobs running on it must request the "sanquentin" license, issued from a pool of five licenses which caps the number of concurrent runners at five even if there are no GPU conflicts.

### Job lifecycle

Once a SLURM job reaches the head of the queue and is eligible to run (all requested licenses have been secured), the prolog script in `slurm/prolog.sh` is executed on the orchestrator VM. Currently the only task in this script is a call to `vm/spawn-vm`.

The `spawn-vm` script determines the node the job is running on, then invokes the appropriate virtualization CLI tool (utmctl or xo-cli as appropriate) to launch the requested runner instance. Once the VM has started, it calls `vm/wait-for-boot` which polls the runner once per second until it accepts SSH connections.

After the runner is up and responding to SSH, if it's an Arch instance, it is fully updated (`pacman -Syu --noconfirm --needed`) and rebooted, then `wait-for-boot` is invoked again to block until the reboot has completed.

At this point the actual SLURM job payload is invoked *on the orchestrator VM* (since the slurmd is running on the orchestrator, because the jobs are scheduled before the worker VMs are created). The typical payload is `vm/run-task` for Linux runners, `vm/run-task-macos` for MacOS runners, or `vm/run-task-msys` for the Windows runner. These are trivial launchers which SFTP the appropriate CI payload from `scopehal-test-scripts/ci-jobs/` to the runner instance, then launch it via SSH on the runner.

Once the actual CI job has been completed by run-task, all generated binaries, PDFs, and other build artifacts are SFTP'd from `~/artifacts` on the runner VM to `/home/ci/artifacts/$SLURM_JOB_ID` on the orchestrator.

Jobs have a 45-minute time limit and will be automatically terminated if not completed after this time has elapsed.

After the job completes or is canceled, SLURM calls `slurm/epilog.sh` on the orchestrator VM, which then calls `vm/wipe-vm` to terminate the runner instance and revert it to a snapshot so it is ready for the next job.

### Postprocessing

After all build jobs have completed, a job runs on the "postprocess" virtual SLURM node (which executes entirely on the orchestrator VM without spawning a worker VM). This job executes `postprocess.sh` which creates public directories on the static-file download server, uploads the generated build artifacts and logs, and then deletes the local copies of them to avoid exhausting disk space on the orchestrator.
