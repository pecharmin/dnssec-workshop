#!/bin/bash
# scripts/startup-docker-host.sh
# Startup KVM Docker Host

[ $UID -ne 0 ] && echo "ERROR: $0 has to be executed as root." >&2 && exit 1

set -x
set -e

/etc/init.d/libvirtd start
virsh start docker-host
