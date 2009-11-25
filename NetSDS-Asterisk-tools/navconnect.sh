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

echo "GET VARIABLE MEMBERINTERFACE"
mi=`checkresults`
agentnum=${mi:18:4}
echo "SET VARIABLE CDR(userfield) PSEUDO_ANSWER|$cdruuid"
checkresults > /dev/null
echo "DATABASE PUT SIP/$agentnum dnd 1"
checkresults > /dev/null
echo "DATABASE GET $agentnum ip"
AGENTIP=`checkresults|egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}"`
PORT=6001
DATA="Message: ActivateCard. Operator: ${agentnum}. CallerID: ${calleridnum}.."
Message=none
Error=none
echo -e "Message: ActivateCard. Operator: ${agentnum}. CallerID: ${calleridnum} \n\n" | netcat ${AGENTIP} ${PORT}
echo "Message: ActivateCard. Operator: ${agentnum}. CallerID: ${calleridnum}" >>/var/log/asterisk/navconnect.log
exit 0

