#!/bin/sh

for x in *.wav
do
                mv $x $x.tmp
                sox $x.tmp -t wav -c 1 -r 8000 $x
                rm $x.tmp
done

