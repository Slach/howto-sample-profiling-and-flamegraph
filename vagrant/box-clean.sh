# clean disk before packaging
#!/usr/bin/env bash
set -exuv -o pipefail

apt-get autoremove -y && apt-get clean -y && apt autoclean -y

echo 'Cleanup log files'
journalctl --flush && journalctl --rotate && journalctl --vacuum-time=1s
find /var/log -type f | while read f; do echo -ne '' > $f; done
echo 'Cleanup temporary files'
rm -rf /tmp/*
rm -rf /var/cache/apt/*

echo 'Cleanup bash history'
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history

# Clean up unused space
dd if=/dev/zero of=/EMPTY bs=64k || true
rm -f /EMPTY
sync

systemctl poweroff