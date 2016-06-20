# dockermonster
This a test for docker deployment on OpenShift running the monster demo app against a local (not OSE) mysql database
The idea is to use it in combination with the AllInOne demobuilder environment using a docker strategy for build.

This is just to show how an application which is running locally can be deployed in OpenShift without modifications.

Be careful: The database configuration is hardcoded in (ticket-monster.war)/WEB-INF/ticket-monster-ds.xml

**STEP 1 - Local Test**

- Take a look to the ticket-monster-ds.xml
- Create a mysql database on the local host as configured in ticket-monster-ds.xml
- Deploy it in a local JBoss EAP 6.4 instance
- Test that it works correctly

Notes:

If you experience problems with MariaDB access permission take a look at:
  https://mariadb.com/kb/en/mariadb/configuring-mariadb-for-remote-client-access/
  
Probably you will need to execute the mysql command and then run:
```
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%' WITH GRANT OPTION;
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.%' WITH GRANT OPTION;
```
**STEP 2 - Create OSE Project**

- Create a new app running the following command

   `$ oc new-app git://github.com/marmendo/dockermonster`

   After some seconds it will launch a builder
   Once the builder finished you must create the route

   `$ oc expose service/dockermonster -l name=dockermonster`

   Once the builder ends you must:
   - Add a route with path "ticket-monster" from the Openshift Web Console
   - TODO
       - I looks like this is not possible to create a route with path (app context) on OSE 3.1.1
          Probably could be possible using a json or yaml file, but I couldn't find a valid example
          Copying the application as ROOT.war made the trick!!   Solved!!

       - Still looking for a way to publish jolokia (8778) service (it works ok in demobuilder monster app) Why??
       ```
           bin/standalone.conf:# Install the Jolokia agent      
           bin/standalone.conf:JAVA_OPTS="$JAVA_OPTS -Xbootclasspath/p:${JBOSS_MODULES_JAR}
           :${JBOSS_LOGMANAGER_JAR}:${JBOSS_LOGMANAGER_EXT_JAR} -Djava.util.logging.manager
           =org.jboss.logmanager.LogManager -javaagent:$JBOSS_HOME/jolokia.jar=port=8778,pr
           otocol=https,caCert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt,clientP
           rincipal=cn=system:master-proxy,useSslClientAuthentication=true,extraClientCheck
           =true,host=0.0.0.0,discoveryEnabled=false" 
        ```
Note: If something goes wrong you can delete dockermonster using:

`$ oc delete all --all -n dockermonster`


