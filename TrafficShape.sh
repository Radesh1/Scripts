#!/bin/bash

########################################################
#VARIAVEIS

int_down=eth1
int_up=eth0
upload=1mbit
download=1mbit
mark=10
ip=10.0.0.0/24

########################################################
 
start() {

#CRIACAO DAS FILAS

tc qdisc add dev $int_up ingress
tc qdisc add dev $int_up root handle 1: htb r2q 0
tc class add dev $int_up parent 1: classid 1:1 htb rate $upload

tc qdisc add dev $int_down ingress
tc qdisc add dev $int_down root handle 1: htb r2q 0
tc class add dev $int_down parent 1: classid 1:1 htb rate $download

#####################################################################################################
#FILTRO DE DOWNLOAD

tc class add dev $int_down parent 1:1 classid 1:$mark htb rate $download
tc filter add dev $int_down protocol ip parent 1:0 prio 1 u32 match ip dst $ip flowid 1:$mark

#####################################################################################################
#FILTRO DE UPLOAD

tc class add dev $int_up parent 1:1 classid 1:$mark htb rate $upload
tc filter add dev $int_up parent 1:0 protocol ip prio 1 handle $mark fw classid 1:$mark

#####################################################################################################
#CRIACAO DA REGRA NO FIREWALL

iptables -t mangle -A POSTROUTING -s $ip -j MARK --set-mark $mark

#####################################################################################################

}

stop() {

    iptables -F -t mangle
    iptables -X -t mangle
    tc qdisc del dev $int_down root
    tc qdisc del dev $int_down ingress
    tc qdisc del dev $int_up root
    tc qdisc del dev $int_up ingress

}

restart() {

    stop
    sleep 1
    start

}

show() {

    tc -s qdisc ls dev $int_down
    tc -s qdisc ls dev $int_up

}

case "$1" in

  start)

    echo -n "Starting bandwidth shaping: "
    start
    echo "done"
    ;;

  stop)

    echo -n "Stopping bandwidth shaping: "
    stop
    echo "done"
    ;;

  restart)

    echo -n "Restarting bandwidth shaping: "
    restart
    echo "done"
    ;;

  show)
    	    	    
    echo "Bandwidth shaping status for $IF:\n"
    show
    echo ""
    ;;

  *)

    pwd=$(pwd)
    echo "Usage: $(/usr/bin/dirname $pwd)/tc.bash {start|stop|restart|show}"
    ;;

esac

exit 0
