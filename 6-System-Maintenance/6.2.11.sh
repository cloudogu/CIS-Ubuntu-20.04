#!/bin/bash

usrs_with_id_0=`awk -F: '($3 == 0) { print $1 }' /etc/passwd`
flag=`echo $a|awk '{print match($0,"root")}'`;

if [ $flag -gt 0 ];then

    echo "Success";
else
    echo "Fail";
fi

awk -F: '($3 == 0) { print $1 }' /etc/passwd wc -l