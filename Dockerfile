# OpenAM Enterprise Subscription Docker image
# Version 1

# If you loaded redhat-rhel-server-7.0-x86_64 to your local registry, uncomment
# this FROM line instead:
# FROM registry.access.redhat.com/rhel 
# Pull the rhel image from the local repository
FROM conductdocker/rhel7:latest 

MAINTAINER Kim Daniel Engebretsen 

#ENV CATALINA_HOME /usr/local/tomcat
#ENV PATH $CATALINA_HOME/bin:$PATH
#RUN mkdir -p "$CATALINA_HOME"
#WORKDIR $CATALINA_HOME
ENV JAVA_HOME /usr/lib/jvm/jre
ENV IP grep $HOSTNAME /etc/hosts | cut -f1 -s

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
#RUN openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 999 -nodes -subj "/CN=am"
#RUN openssl pkcs12 -export -in cert.pem -inkey key.pem -out keystore.p12 -name tls -password env:STOREPASS
#RUN keytool -importkeystore -deststorepass $STOREPASS -destkeypass $STOREPASS -destkeystore keystore.jceks -deststoretype JCEKS -srckeystore keystore.p12 -srcstoretype PKCS12 -srcstorepass $STOREPASS -alias tls

# Trust OpenDJ and OpenIDM
#RUN echo -n | openssl s_client -connect openidm:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/openidm-selfsigned.cert.pem
#RUN echo -n | openssl s_client -connect opendj:1636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/opendj-selfsigned.cert.pem

WORKDIR /opt/openam/
ADD sso /var/lib/tomcat/webapps/sso
#ADD keystore.jceks /opt/openam/docker-config/keystore.jceks
#ADD cert.pem /opt/openam/docker-config/cert.pem

ADD SSOConfiguratorTools-12.0.1.zip docker-config/SSOConfiguratorTools-12.0.1.zip
ADD SSOAdminTools-12.0.1.zip docker-config/SSOAdminTools-12.0.1.zip
RUN unzip /opt/openam/docker-config/SSOConfiguratorTools-12.0.1.zip -d /opt/openam/configurator
RUN unzip /opt/openam/docker-config/SSOAdminTools-12.0.1.zip -d /opt/openam/tools


ADD server.sh /opt/openam/server.sh
#RUN cp /opt/openam/docker-config/cert.pem /etc/pki/ca-trust/source/anchors/openam-selfsigned.cert.pem
#RUN update-ca-trust extract
ADD configurator.properties docker-config/configurator.properties
ADD run.sh /opt/openam/run.sh
CMD ["/opt/openam/run.sh"]
