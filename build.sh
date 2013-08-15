#!/bin/bash

# BEGIN: User defined variables #
# Variables that define the version and commit to pull from Github
# These need to be changed when the source is updated
commit="0b4546e89ded86d2f11727d32fb1eb2caaf91ceb"
short_commit=$(echo $commit | cut -c1-7)
version="0.5"
spec_name="zfs-arcstat"
git_url_base="https://github.com"
git_url_path="zfsonlinux/arcstat/archive/${commit}/${tarball}"
# END: User defined variables #

# Default variables that have command line flags
QUIET=1
DEBUG=0
TRACE=0
DIST="all"

# Get the full path of this script's directory
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

usage () {

cat << EOF
usage: $(basename $0) [OPTIONS]

This script builds RPMs for $spec_name.

OPTIONS:

  -d, --dist      Distribution to use.
                  Valid options are 5, 6, or all.
                  Default: all
  --debug         Show debug output
                  This option also removes mock's --quiet option.
  --trace         Show mock's debug output
  -h, --help      Show this message

EXAMPLE:

Build both EL6 and EL5 RPMs

$(basename $0) --dist all

Build only EL6 RPMs

$(basename $0) --dist 6

Run with this script's debug output and mock's normal output

$(basename $0) --debug

Enable all debug output and mock's trace output

$(basename $0) --debug --trace

EOF
}

ARGS=`getopt -o hd: -l help,debug,trace,dist: -n "$0" -- "$@"`

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
    -d|--dist)
      DIST="$2"
      shift 2
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

# Validate the --dist option
if [ "$DIST" -ne 6 ] 2>/dev/null && [ "$DIST" -ne 5 ] 2>/dev/null && [ "$DIST" != "all" ] 2>/dev/null; then
  echo "--dist must be 5, 6, or all"
  usage
  exit 1
fi

# Set variables based on command line flags
[ $DEBUG -eq 1 ] && set -x
[ $TRACE -eq 1 ] && mock_trace="--trace" || mock_trace=""
[ $QUIET -eq 1 ] && mock_quiet="--quiet" || mock_quiet=""
[ "$DIST" == "all" ] && DIST="6 5"

tarball="${spec_name}-${version}-${short_commit}.tar.gz"
repo_url="${git_url_base}/${git_url_path}"

# Download source tarball if not present
if [ ! -e ${SCRIPTPATH}/SOURCES/${tarball} ]; then
  curl -L -o ${SCRIPTPATH}/SOURCES/${tarball} ${repo_url}
fi

for d in $DIST
do
  # Set the digset used for RPMbuild and mock's rpmbuild
  # This is necessary because the default digest in EL6 will
  # create unusable RPMs for EL5
  if [ "$d" -eq 5 ]; then
    DIGEST="md5"
  else
    DIGEST="sha256"
  fi

  # Create SRPM
  srpm_out=$(rpmbuild -bs --define "dist .el${d}" --define "_source_filedigest_algorithm ${DIGEST}" --define "_binary_filedigest_algorithm ${DIGEST}" ${SCRIPTPATH}/SPECS/${spec_name}.spec)
  srpm_ret=$?
  [ $srpm_ret != 0 ] && { echo "rpmbuild of SRPM for dist ${d} failed!"; continue; }

  # Get SRPM's path from rpmbuild output
  srpm=$(echo $srpm_out | awk -F" " '{print $2}')

  # Run mock rebuild
  cmd="mock -r epel-${d}-x86_64 --define=\"dist .el${d}\" ${mock_quiet} ${mock_trace} --resultdir=${SCRIPTPATH}/results/el${d} --rebuild ${srpm}"
  echo "Executing: ${cmd}"
  eval $cmd
  mock_ret=$?
  [ $mock_ret != 0 ] && { echo "Mock rebuild of ${srpm} failed!"; continue; }
done

exit 0
