# OpenAM Enterprise Subscription Docker image
# Version 1

# If you loaded redhat-rhel-server-7.0-x86_64 to your local registry, uncomment
# this FROM line instead:
# FROM registry.access.redhat.com/rhel 
# Pull the rhel image from the local repository
FROM rhel 

MAINTAINER Kim Daniel Engebretsen 

#ENV CATALINA_HOME /usr/local/tomcat
#ENV PATH $CATALINA_HOME/bin:$PATH
#RUN mkdir -p "$CATALINA_HOME"
#WORKDIR $CATALINA_HOME
ENV JAVA_HOME /usr/lib/jvm/jre
ENV IP grep $HOSTNAME /etc/hosts | cut -f1 -s
ENV STOREPASS Secret1

# Update image
RUN yum update -y && \
#RPM_URL=$(curl http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html |grep -o http://download.oracle.com.*jdk.*x64\.rpm) && \
#curl -k -L -o jdk-8.rpm --header "Cookie: oraclelicense=accept-securebackup-cookie" $RPM_URL && \
#yum localinstall -y jdk-8.rpm && rm jdk-8.rpm && \
yum install -y which grep sed awk unzip openssl java-1.7.0-openjdk-devel tomcat && \
yum clean all

# Create an index.html file
RUN mkdir -p /opt/openam/docker-config
RUN mkdir /opt/openam/configurator
RUN mkdir /opt/openam/tools

# If only we've had openssl------------
WORKDIR /opt/openam/docker-config
RUN openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 999 -nodes -subj "/CN=am"
RUN openssl pkcs12 -export -in cert.pem -inkey key.pem -out keystore.p12 -name tls -password env:STOREPASS
RUN keytool -importkeystore -deststorepass $STOREPASS -destkeypass $STOREPASS -destkeystore keystore.jceks -deststoretype JCEKS -srckeystore keystore.p12 -srcstoretype PKCS12 -srcstorepass $STOREPASS -alias tls

# Trust OpenDJ and OpenIDM
#RUN echo -n | openssl s_client -connect openidm:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/openidm-selfsigned.cert.pem
#RUN echo -n | openssl s_client -connect opendj:1636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/opendj-selfsigned.cert.pem

WORKDIR /opt/openam/
ADD OpenAM-12.0.1.war /var/lib/tomcat/webapps/sso.war
#ADD keystore.jceks /opt/openam/docker-config/keystore.jceks
#ADD cert.pem /opt/openam/docker-config/cert.pem

ADD SSOConfiguratorTools-12.0.1.zip docker-config/SSOConfiguratorTools-12.0.1.zip
ADD SSOAdminTools-12.0.1.zip docker-config/SSOAdminTools-12.0.1.zip
RUN unzip /opt/openam/docker-config/SSOConfiguratorTools-12.0.1.zip -d /opt/openam/configurator
RUN unzip /opt/openam/docker-config/SSOAdminTools-12.0.1.zip -d /opt/openam/tools

RUN NEWSTRING='    <Connector port="8443" protocol="HTTP\/1.1" SSLEnabled="true" \
               maxThreads="150" scheme="https" secure="true" \
               clientAuth="false" sslProtocol="TLS" \
               keystoreFile="\/opt\/openam\/docker-config\/keystore.jceks" keystorePass="'$STOREPASS'" keystoreType="JCEKS" keyAlias="tls" \/>'; \
eval "sed -i 's/^.*Define an AJP 1.3 Connector on port 8009.*$/$NEWSTRING\n\n\0/g' /etc/tomcat/server.xml";

#RUN echo $(grep $HOSTNAME /etc/hosts | cut -f1) openam.localdomain.local >> /etc/hosts && \
#/opt/openam/run.sh & echo "Waiting 30 sec for tomcat"; sleep 30;\
#${JAVA_HOME}/bin/java -jar /opt/openam/configurator/openam-configurator-tool-12.0.1.jar -f /opt/openam/docker-config/configurator.properties; \
#/opt/openam/tools/setup --acceptLicense -p /opt/openam/; \
## Need extra config for site/loadbalance config 
#LB="$(grep ^LB_PRIMARY_URL docker-config/configurator.properties | sed 's/.*=//g' | sed 's/\//\\\//g')" ;\
#NEWSTRING='-D"com.iplanet.am.naming.map.site.to.server='$LB'=https:\/\/openam.localdomain.local:8443\/sso" \\\n    '; \
## Speed up ssoadm with better random entropy source
#NEWSTRING=$NEWSTRING'-D"java.security.egd=file:\/dev\/.\/urandom" \\\n    '; \
#eval "sed -i 's/com.sun.identity.cli.CommandManager/$NEWSTRING\0/g' /opt/openam/tools/sso/bin/ssoadm";
#
#RUN /opt/openam/run.sh; \ #echo "Waiting 30 sec for tomcat"; sleep 30;\
#/opt/openam/tools/sso/bin/ssoadm list-servers -u amadmin -f /opt/openam/.pass

ADD server.sh /opt/openam/server.sh
RUN cp /opt/openam/docker-config/cert.pem /etc/pki/ca-trust/source/anchors/openam-selfsigned.cert.pem
RUN update-ca-trust extract
ADD configurator.properties docker-config/configurator.properties
RUN grep ^ADMIN_PWD /opt/openam/docker-config/configurator.properties | cut -f2 -d'=' > /opt/openam/.pass; chmod 400 /opt/openam/.pass;
ADD run.sh /opt/openam/run.sh
EXPOSE 8080
CMD ["/opt/openam/run.sh"]
