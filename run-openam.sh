#!/bin/sh
# Start OpenAM
# To create a persistent configuration mount a data volume on /openam/root

#  Point instance dir at /root/openam
mkdir -p /root/.openamcfg
cat >/root/.openamcfg/AMConfig_usr_local_tomcat_webapps_openam_ <<HERE
/root/openam
HERE

cd $CATALINA_HOME
if [ ! -e "$openambin" ] && [ -s "$openamzip" ]; then
	echo "Unzipping $openamzip"
	unzip -qn $openamzip -d /opt/repo/bin
fi
if [ -e "$openambin" ]; then
	mv $openambin/*STS-Server*.war $openambin/STS-Server.war
	cp -r $openambin/AM*.war webapps/openam.war
else
	echo "Did not find any openam folder at $openambin, and don't have any open access to zipfile $openamzip"	
fi

cd /usr/local/tomcat 
bin/catalina.sh run 

