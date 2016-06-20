# dockermonster
This a test for docker deployment on OpenShift running the monster demo app against a local (not ose) mysql database
The idea is to use it in combination with the AllInOne demobuilder environment.

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
   
   Once the builder ends you must:
   * Add a route with path "ticket-monster" from the Openshift Web Console
   - I didn't find a way to do this from oc
   - I didn't find the way to publish jolokia (8778) service.
   

Note: If something goes wrong you can delete dockermonster using:

`$ oc delete all --all -n dockermonster`


