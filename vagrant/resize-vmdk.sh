#!/usr/bin/env bash
set -exuv -o pipefail
vagrant halt
mkdir -pv "${FLAMEGRAPH_VAGRANT}"
MACHINE_ID=$(cat .vagrant/machines/profiling/virtualbox/id)
HDD_FILE=$(VBoxManage showvminfo --machinereadable ${MACHINE_ID} | grep "SCSI-0-0" | cut -d '=' -f 2 | tr -d "\n" | tr -d "\r" | tr -d '"')
CLONED_VDI="${FLAMEGRAPH_VAGRANT}/cloned.vdi"
if [[ "$OSTYPE" == cygwin* ]]; then
    CLONED_VDI=`cygpath -w -l ${CLONED_VDI}`
fi

test -f "${CLONED_VDI}" && VBoxManage closemedium disk "${CLONED_VDI}" --delete || true
VBoxManage clonemedium disk "${HDD_FILE}" "${CLONED_VDI}" --format VDI
VBoxManage storageattach ${MACHINE_ID} --storagectl "SCSI" --port 0 --medium none
VBoxManage closemedium disk "${HDD_FILE}" --delete
VBoxManage modifyhd "${CLONED_VDI}" --resize 122880 # 120 GB
VBoxManage clonehd "${CLONED_VDI}" "${HDD_FILE}" --format VMDK
VBoxManage storageattach ${MACHINE_ID} --storagectl "SCSI" --port 0 --type hdd --medium "${HDD_FILE}"
VBoxManage closemedium disk "${CLONED_VDI}" --delete
