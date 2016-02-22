#!/bin/bash
# /etc/bind/scripts/zone-update.sh [-c|--check] [<tld1 tld2> [<overwrite_soa_serial>]

ZONEFILE_DIR=/etc/bind/zones

RUN_CHECK=0
if [ "$1" = "-c" -o "$1" = "--check" ]
then
	shift
	RUN_CHECK=1
fi

ZONES=${1:-"linuxtage.de dnssec.de arminpech.de"}
FORCE_SERIAL=$2

echo "[$(date)] Starting $0"
for tld in $ZONES
do
	echo "=== $tld ==="
	$(dirname $0)/update-zone-from-db.sh $tld $FORCE_SERIAL
	$(dirname $0)/sign-zone.sh $tld
	echo
done

if [ $RUN_CHECK -eq 1 ]
then
	RET=0
	for tld in $ZONES
	do
		if [ -e "${ZONEFILE_DIR}/${tld}.zone.signed" ]
		then
			named-checkzone ${tld}. ${ZONEFILE_DIR}/${tld}.zone.signed
		elif [ -e "${ZONEFILE_DIR}/${tld}.zone" ]
		then
			named-checkzone ${tld}. ${ZONEFILE_DIR}/${tld}.zone
		else
			echo "ERROR: Found no zone file for TLD $tld" >&2
			err=$?
			[ $err -gt 0 ] && RET=$err
		fi
	done

	[ $RET -ne 0 ] && exit $RET
fi

rndc reload
