#!/bin/bash

commit="0b4546e89ded86d2f11727d32fb1eb2caaf91ceb"
short_commit=$(echo $commit | cut -c1-7)
version="0.5"

tarball="zfs-arcstat-${version}-${short_commit}.tar.gz"
repo_url="https://github.com/zfsonlinux/arcstat/archive/${commit}/${tarball}"

if [ ! -e SOURCES/${tarball} ]; then
  curl -L -o SOURCES/${tarball} ${repo_url}
fi

out=$(rpmbuild -bs zfs-arcstat.spec)
srpm=$(echo $out | awk -F" " '{print $2}')

mock -r epel-6-x86_64 --rebuild ${srpm}

exit 0
