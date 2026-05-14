#!/bin/bash

# Log header
echo "Postprocessing running for jobs $@ from commit $COMMIT on branch $BRANCH"

# Convert positional arguments to friendly named SLURM job IDs
WIN11_JOB=$1
DEBIAN_OLDSTABLE_JOB=$2
UBUNTU_OLDLTS_JOB=$3
ARCH_JOB=$4
DEBIAN_STABLE_JOB=$5
UBUNTU_LTS_JOB=$6
FEDORA_JOB=$7
MACOS_JOB=$8

# Get the short commit hash (for now truncate to 8 chars)
SHORT_HASH=`echo $COMMIT | cut -c 1-8`

# Get the date fields
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`
MINUTE=`date +%M`
TIMEZONE=`date +%Z`

# Get the full build directory name, makign sure to include the git hash but also the full date and time
# Skip seconds, builds are slow enough we should never have >1 per minute and the hash will disambiguate anyway
BUILD="$YEAR-$MONTH-$DAY-$HOUR$MINUTE$TIMEZONE-$SHORT_HASH"

# Make the build directories on the static-file server
FILE_HOST=dl1.antikernel.net
ssh ci@$FILE_HOST /var/home/ci/mkdirs.sh $YEAR $MONTH $BUILD

# Push artifacts
OUTBASE=/var/dl/ngscopeclient-ci/$YEAR/$MONTH/$BUILD
scp artifacts/$WIN11_JOB/* ci@$FILE_HOST:$OUTBASE/win11-x64/
scp artifacts/$DEBIAN_OLDSTABLE_JOB/* ci@$FILE_HOST:$OUTBASE/debian-12-amd64/
scp artifacts/$UBUNTU_OLDLTS_JOB/* ci@$FILE_HOST:$OUTBASE/ubuntu-24-04-amd64/
scp artifacts/$ARCH_JOB/* ci@$FILE_HOST:$OUTBASE/arch-amd64/
scp artifacts/$DEBIAN_STABLE_JOB/* ci@$FILE_HOST:$OUTBASE/debian-13-amd64/
scp artifacts/$UBUNTU_LTS_JOB/* ci@$FILE_HOST:$OUTBASE/ubuntu-26-04-amd64/
scp artifacts/$FEDORA_JOB/* ci@$FILE_HOST:$OUTBASE/fedora-43-amd64/
scp artifacts/$MACOS_JOB/* ci@$FILE_HOST:$OUTBASE/macos-15-6-arm64/

# Push build logs for debugging
scp run-logs/slurm-$WIN11_JOB.out ci@$FILE_HOST:$OUTBASE/win11-x64/buildlog.txt
scp run-logs/slurm-$DEBIAN_OLDSTABLE_JOB.out ci@$FILE_HOST:$OUTBASE/debian-12-amd64/buildlog.txt
scp run-logs/slurm-$UBUNTU_OLDLTS_JOB.out ci@$FILE_HOST:$OUTBASE/ubuntu-24-04-amd64/buildlog.txt
scp run-logs/slurm-$ARCH_JOB.out ci@$FILE_HOST:$OUTBASE/arch-amd64/buildlog.txt
scp run-logs/slurm-$DEBIAN_STABLE_JOB.out ci@$FILE_HOST:$OUTBASE/debian-13-amd64/buildlog.txt
scp run-logs/slurm-$UBUNTU_LTS_JOB.out ci@$FILE_HOST:$OUTBASE/ubuntu-26-04-amd64/buildlog.txt
scp run-logs/slurm-$FEDORA_JOB.out ci@$FILE_HOST:$OUTBASE/fedora-43-amd64/buildlog.txt
scp run-logs/slurm-$MACOS_JOB.out ci@$FILE_HOST:$OUTBASE/macos-15-6-arm64/buildlog.txt

# TODO: clean up local copies of artifacts and build logs
