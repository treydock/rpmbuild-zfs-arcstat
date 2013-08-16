#!/bin/bash

# BEGIN: User defined variables #
# Variables that define the version and commit to pull from Github
# These need to be changed when the source is updated
commit="0b4546e89ded86d2f11727d32fb1eb2caaf91ceb"
short_commit=$(echo $commit | cut -c1-7)
version="0.5"
spec_name="zfs-arcstat"
git_url_base="https://github.com"
git_url_path="zfsonlinux/arcstat/archive"
# END: User defined variables #

# Default variables that have command line flags
QUIET=1
DEBUG=0
TRACE=0

# Get the full path of this script's directory
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

usage () {

cat << EOF
usage: $(basename $0) [OPTIONS]

This script builds RPMs for $spec_name.

OPTIONS:

  --debug         Show debug output
                  This option also removes mock's --quiet option.
  --trace         Show mock's debug output
  -h, --help      Show this message

EXAMPLE:

Build EL6 RPMs

$(basename $0)

Run with this script's debug output and mock's normal output

$(basename $0) --debug

Enable all debug output and mock's trace output

$(basename $0) --debug --trace

EOF
}

ARGS=`getopt -o h -l help,debug,trace -n "$0" -- "$@"`

[ $? -ne 0 ] && { usage; exit 1; }

eval set -- "${ARGS}"

while true; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --debug)
      DEBUG=1
      QUIET=0
      shift
      ;;
    --trace)
      TRACE=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

# Set variables based on command line flags
[ $DEBUG -eq 1 ] && set -x
[ $TRACE -eq 1 ] && mock_trace="--trace" || mock_trace=""
[ $QUIET -eq 1 ] && mock_quiet="--quiet" || mock_quiet=""

tarball="${spec_name}-${version}-${short_commit}.tar.gz"
repo_url="${git_url_base}/${git_url_path}/${commit}/${tarball}"

# Download source tarball if not present
if [ ! -e ${SCRIPTPATH}/SOURCES/${tarball} ]; then
  curl -L -o ${SCRIPTPATH}/SOURCES/${tarball} ${repo_url}
fi

# Create SRPM
srpm_out=$(rpmbuild -bs --define "dist .el6" ${SCRIPTPATH}/SPECS/${spec_name}.spec)
srpm_ret=$?
[ $srpm_ret != 0 ] && { echo "rpmbuild of SRPM failed!"; continue; }

# Get SRPM's path from rpmbuild output
srpm=$(echo $srpm_out | awk -F" " '{print $2}')

# Run mock rebuild
cmd="mock -r epel-6-x86_64 ${mock_quiet} ${mock_trace} --resultdir=${SCRIPTPATH}/results/el6 --rebuild ${srpm}"
echo "Executing: ${cmd}"
eval $cmd
mock_ret=$?
[ $mock_ret != 0 ] && { echo "Mock rebuild of ${srpm} failed!"; continue; }

exit 0
