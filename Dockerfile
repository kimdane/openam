FROM tomcat:8-jre8

MAINTAINER kimdane
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV openambin=/opt/repo/bin/openam
ENV openamzip=/opt/repo/bin/zip/openam.zip

WORKDIR $CATALINA_HOME

ADD run-openam.sh /opt/run-openam.sh
EXPOSE 8080

VOLUME ["/opt/repo"]

CMD ["/opt/run-openam.sh"]
