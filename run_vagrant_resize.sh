#!/usr/bin/env bash
vagrant destroy -f
vagrant up --provision
TMPDIR=$(mktemp -d)
FLAMEGRAPH_VAGRANT=${TMPDIR}/k8s-vagrant
if [[ "$OSTYPE" == cygwin* ]]; then
    FLAMEGRAPH_VAGRANT=`cygpath -w -l ${FLAMEGRAPH_VAGRANT}`
fi
rm -rfv "${FLAMEGRAPH_VAGRANT}/*"
bash -c "SCRIPT=vagrant/box-clean.sh vagrant reload --provision"
bash -x -c "FLAMEGRAPH_VAGRANT='${FLAMEGRAPH_VAGRANT}' ./vagrant/resize-vmdk.sh"
bash -c "SCRIPT=vagrant/repartition.sh vagrant reload --provision"
