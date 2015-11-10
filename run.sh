#!/bin/bash


echo "Secret1" > /opt/openam/.keystorepass
echo "Secret1" > /opt/openam/.ldappass
echo "Secret123" > /opt/openam/.pass
if [ -e "/secrets/ampass" ]
then
	cp /secrets/ampass /opt/openam/.pass
fi
chmod 400 /opt/openam/.pass;
if [ -e "/secrets/ldappass" ]
then
	cp /secrets/ldappass /opt/openam/.ldappass
fi
if [ -e "/secrets/keystorepass" ] && [ -e "/secrets/keystore.jceks" ]
then
	NEWSTRING='    <Connector port="8443" protocol="HTTP\/1.1" SSLEnabled="true" \
	               maxThreads="150" scheme="https" secure="true" \
	               clientAuth="false" sslProtocol="TLS" \
	               keystoreFile="\/secrets\/keystore.jceks" keystorePass="'$(cat /secrets/keystorepass)'" keystoreType="JCEKS" keyAlias="tls" \/>'; \
	eval "sed -i 's/^.*Define an AJP 1.3 Connector on port 8009.*$/$NEWSTRING\n\n\0/g' /etc/tomcat/server.xml";
fi
cat <(echo -n "USERSTORE_PASSWD=") /opt/openam/.ldappass >> /opt/openam/docker-config/configurator.properties
cat <(echo -n "ADMIN_PWD=") /opt/openam/.pass >> /opt/openam/docker-config/configurator.properties 


echo $(grep $HOSTNAME /etc/hosts | cut -f1) am >> /etc/hosts
nohup /opt/openam/server.sh &

echo "Waiting 30 sec for tomcat"; 
sleep 45
${JAVA_HOME}/bin/java -jar /opt/openam/configurator/openam-configurator-tool-12.0.1.jar -f /opt/openam/docker-config/configurator.properties

cd /opt/openam/tools/; /opt/openam/tools/setup --acceptLicense -p /opt/openam

# Need extra config for site/loadbalance config 
#LB="$(grep ^LB_PRIMARY_URL /opt/openam/docker-config/configurator.properties | sed 's/.*=//g' | sed 's/\//\\\//g')"
#NEWSTRING='-D"com.iplanet.am.naming.map.site.to.server='$LB'=https:\/\/openam.localdomain.local:8443\/sso" \\\n    '
# Speed up ssoadm with better random entropy source
#NEWSTRING=$NEWSTRING'-D"java.security.egd=file:\/dev\/.\/urandom" \\\n    '
#eval "sed -i 's/com.sun.identity.cli.CommandManager/$NEWSTRING\0/g' /opt/openam/tools/sso/bin/ssoadm"
/opt/openam/tools/sso/bin/ssoadm list-servers -u amadmin -f /opt/openam/.pass
tail -f /var/log/tomcat/catalina.out
