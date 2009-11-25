#!/bin/bash
calleridnum=$1
cdruuid=$2

checkresults() {
        while read line
        do
                case ${line:0:4} in
                        "200 " )
                                echo $line
                                return
                        ;;
                        * )
                                echo $line >&2
                        ;;
                esac
        done
}

echo "SET VARIABLE CDR(userfield) ANSWER|$cdruuid"
checkresults > /dev/null
exit 0

