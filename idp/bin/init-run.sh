#!/bin/bash
/usr/sbin/sshd &
/usr/local/tomcat/bin/catalina.sh run &
/usr/sbin/apache2ctl -D FOREGROUND
