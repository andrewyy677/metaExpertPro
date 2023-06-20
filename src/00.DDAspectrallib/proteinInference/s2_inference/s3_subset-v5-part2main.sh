#!/bin/bash
##
## run the perl scripts subset-v5-part2.pl
##
find trim/in/ -maxdepth 1 -name "*.in.txt" | \
xargs -n 1 -P 32 -I PREFIX \
sh -c '
pre=$(basename PREFIX)
prein=${pre%%.*}
echo ${prein}
if [ ${prein} -gt "9" ]
then
echo PREFIX
perl subset-v5-part2.pl PREFIX
fi
'
