#!/bin/bash
# 

RESOURCE=mysql_data1
PARTNER_HOST=lepka01

do_status()
{
	echo -e "\n$HOSTNAME drbd status:\n" 
	cat /proc/drbd 
	echo -e "\n$PARTNER_HOST drbd status:\n" 
	ssh $PARTNER_HOST cat /proc/drbd 
	echo -e "\n\n"
}

do_watch()
{
	watch $0 status		# uau!
}


do_cmd()
{
	# TODO: exit value management
	CMD=$1
	drbdadm $CMD $RESOURCE
	sleep 1			# TODO: needed?
	ssh $PARTNER_HOST "drbdadm $CMD $RESOURCE"
}

case "$1" in
  connect|start)
        do_cmd connect
        ;;
  disconnect|stop)
  	do_cmd disconnect
	;;
  rebuild)
  	# TODO: recover from split brain
        echo "Error: argument '$1' not supported at this time" >&2
        exit 3
        ;;
  sync)
  	# sync config files with partner host
        echo "Error: argument '$1' not supported at this time" >&2
        exit 3
        ;;
  status|"")
	do_status
        ;;
  watch)
  	do_watch
	;;
  *)
        echo "Usage: $0 [connect|disconnect|rebuild|sync|status|watch]" >&2
        exit 3
        ;;
esac

