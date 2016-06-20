FROM registry.access.redhat.com/jboss-eap-6/eap64-openshift:latest
EXPOSE 8080 8888 8778
USER 185
#ADD standalone.xml /opt/eap/standalone/configuration/standalone-openshift.xml
#COPY mysql.tar /opt/eap/modules/system/layers/base/com/mysql.tar
#RUN cd /opt/eap/modules/system/layers/base/com && \
#tar xvf mysql.tar && \
#rm mysql.tar
COPY ticket-monster.war /opt/eap/standalone/deployments/
