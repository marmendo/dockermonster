MAINTAINER Mario Mendoza
#FROM registry.access.redhat.com/jboss-eap-6/eap64-openshift:latest
FROM registry.access.redhat.com/jboss-eap-7/eap70-openshift:latest
EXPOSE 8080 8888 8778
USER 185
COPY ticket-monster.war /opt/eap/standalone/deployments/ROOT.war
