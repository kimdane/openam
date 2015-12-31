#!/bin/sh
# Start OpenAM
# To create a persistent configuration mount a data volume on /openam/root

#  Point instance dir at /root/openam
mkdir -p /root/.openamcfg
cat >/root/.openamcfg/AMConfig_usr_local_tomcat_webapps_openam_ <<HERE
/root/openam
HERE

cd $CATALINA_HOME
file=/opt/repo/bin/staging/openam.war
if [ -s "$file" ]; then
		cp "$file" webapps/openam.war
else
	curl http://download.forgerock.org/downloads/openam/openam_link.js | \
   grep -o "http://.*\.war" | xargs curl -o webapps/openam.war
fi

cd /usr/local/tomcat 
bin/catalina.sh run 

