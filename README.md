# dockermonster
This a test for docker deployment on OpenShift running the monster demo app against a local (not OSE) mysql database
The idea is to use it in combination with the AllInOne demobuilder environment using a docker strategy for build.

This is just to show how a legacy application of medium complexity could be deployed in OpenShift with few or no  modifications using docker builder strategy as a first approach.

Warning!! : The database configuration is hardcoded in (ticket-monster.war)/WEB-INF/ticket-monster-ds.xml

**STEP 0 - Prepare Environment**

- Download JBoss EAP **6.4**: http://developers.redhat.com/products/eap/download/ (under **View Older Downloads ▾**)
- Configure JBoss and the maven repositories (you can download the repos to your local system)
- Add the mysql driver decompressing [mysql.tar](https://github.com/marmendo/dockermonster/blob/master/mysql.tar) in .../jboss-eap-6.4/modules/system/layers/base/com
- Install mariadb or mysql locally. Provide permision to user root without password (see notes below)
- Create a database (schema) named ticketmonster
- Test you access to the schema (mysql workbench is here: https://dev.mysql.com/downloads/workbench)

Notes:

If you experience problems with MariaDB access permission take a look at:
  https://mariadb.com/kb/en/mariadb/configuring-mariadb-for-remote-client-access/
  
Probably you will need to execute the mysql command and then run:
```
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%' WITH GRANT OPTION;
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost%' WITH GRANT OPTION;
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.%' WITH GRANT OPTION;
```

**STEP 1 - Prepare Ticketmonster**

- Download the application here: http://developers.redhat.com/ticket-monster/
- Update the datasource definition in: .../demo/src/main/webapp/WEB-INF/ticket-monster-ds.xml

REPLACE
```
    <datasource jndi-name="java:jboss/datasources/ticket-monsterDS"
        pool-name="ticket-monster" enabled="true" use-java-context="true">
        <connection-url>jdbc:h2:mem:ticket-monster;DB_CLOSE_ON_EXIT=FALSE;DB_CLOSE_DELAY=-1</connection-url>
        <driver>h2</driver>
        <security>
            <user-name>sa</user-name>
            <password>sa</password>
        </security>
    </datasource>
```
BY
```
    <datasource jndi-name="java:jboss/datasources/ticket-monsterDS"
        pool-name="MySQLDS" enabled="true">
        <connection-url>jdbc:mysql://192.168.124.1:3306/ticketmonster</connection-url>
        <driver>mysql</driver>
        <pool>
            <min-pool-size>1</min-pool-size>
            <max-pool-size>10</max-pool-size>
            <prefill>true</prefill>
        </pool>
        <statement>
            <prepared-statement-cache-size>32</prepared-statement-cache-size>
            <share-prepared-statements>true</share-prepared-statements>
        </statement>
        <security>
            <user-name>root</user-name>
            <password></password>
        </security>
    </datasource>
```

In order to configure the database driver in JBOSS-DIR/standalone/configuration/standalone.xml

UNDER
```
       <subsystem xmlns="urn:jboss:domain:datasources:1.2"> 
          <datasources>
              <drivers>
```
INCLUDE the driver definition

  ```
                <driver name="mysql" module="com.mysql">
                    <driver-class>com.mysql.jdbc.Driver</driver-class>
                    <xa-datasource-class>com.mysql.jdbc.jdbc2.optional.MysqlXADataSource</xa-datasource-class>
                </driver>
 ```
 
- Realize that we are using 192.168.124.1:3306 in order to make the database accessible from demobuilder VM
- From the demo folder, compile and pack with: `$ mvn clean package`
- Deploy in local JBoss EAP 6.4 dropping the generated war to JBOSS-DIR/standalone/deployments
- Start JBOSS-DIR/bin/standalone.sh and test that it works correctly
- Navigate to http://localhost:8080/ticket-monster

Works!!  GREAT!!


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


