#!/bin/sh
${JAVA_HOME}/bin/java -server -XX:MaxPermSize=256m -Xmx2048m -cp "/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar" \
		-D"javax.sql.DataSource.Factory=org.apache.commons.dbcp.BasicDataSourceFactory" \
		-D"catalina.base=/usr/share/tomcat" \
		-D"catalina.home=/usr/share/tomcat" \
		-D"java.endorsed.dirs=" \
		-D"java.io.tmpdir=/var/cache/tomcat/temp" \
		-D"java.util.logging.config.file=/usr/share/tomcat/conf/logging.properties" \
		-D"java.util.logging.manager=org.apache.juli.ClassLoaderLogManager" \
		org.apache.catalina.startup.Bootstrap start
