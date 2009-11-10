#!/bin/bash

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
then

DESTINATION=$1
CALLBACK_CONTEXT=$2
CALLBACK_CONNECT=$3

TMPFILE=/tmp/dial-$1
SPOOLFILE=/var/spool/asterisk/outgoing/dial-$1

echo "Channel: Local/$DESTINATION@$CALLBACK_CONTEXT" >$TMPFILE
echo "MaxRetries: 2" >>$TMPFILE
echo "RetryTime: 30" >>$TMPFILE
echo "WaitTime: 30" >>$TMPFILE

#if the call answers connect it here

echo "Context: $CALLBACK_CONNECT" >>$TMPFILE
echo "Extension: $DESTINATION" >>$TMPFILE
echo "Priority: 1" >>$TMPFILE

mv -f $TMPFILE $SPOOLFILE

exit 0;

fi

echo "Callback failed."

exit -1;

