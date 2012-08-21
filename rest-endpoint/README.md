REST Endpoint: Use JDG remotely through REST
============================================
Author: Tristan Tarrent and Martin Gencur
Level: Intermediate
Technologies: Infinispan
Summary: Show how to use Infinispan remotely.

What is it?
-----------

This examples shows connecting to JBoss Data Grid (JDG) remotely and storing, 
retrieving and removing data from caches. All of the apps are variations of a simple Football Manager which is a console 
application. It is possible to add a team, players, remove all the entities and show the listing of all teams/players. 

Nothing complex, just showing basic operations with the cache.


System requirements
-------------------

All you need to build this project is Java 6.0 (Java SDK 1.6) or better, Maven 3.0 or better.

The application this project produces is designed to be run on JBoss Datagrid Server 6.0 

 
Configure Maven
---------------

Contributor: You can copy or link to the Maven configuration information in the README file in the root folder of the quickstarts. For example:

If you have not yet done so, you must [Configure Maven](../README.md#configure-maven-) before testing the quickstarts.


Configure JDG
-------------


0) Install a JDBC driver into JDG. More information can be found at 
   https://community.jboss.org/wiki/DataSourceConfigurationInAS7, topic "Installing a JDBC driver as a module"

NOTE: JDG does not support deploying applications so one cannot install it as a deployment.

1) Alter JDG configuration file (`${JDG_HOME}/standalone/configuration/standalone.xml`) to contain
   the following definitions:
   
* Datasource subsystem definition:

    ```
    <subsystem xmlns="urn:jboss:domain:datasources:1.0">
        <datasources>
            <datasource jndi-name="java:jboss/datasources/ExampleDS" pool-name="ExampleDS" enabled="true" use-java-context="true">
                <connection-url>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1</connection-url>
                <driver>h2</driver>
                <security>
                    <user-name>sa</user-name>
                    <password>sa</password>
                </security>
            </datasource>
            <drivers>
                <driver name="h2" module="com.h2database.h2">
                    <xa-datasource-class>org.h2.jdbcx.JdbcDataSource</xa-datasource-class>
                </driver>
            </drivers>
        </datasources>
    </subsystem>
    ```

* Infinispan subsystem definition:

    ```
    <subsystem xmlns="urn:jboss:domain:infinispan:1.2" default-cache-container="default">
        <cache-container name="default" default-cache="memcachedCache" listener-executor="infinispan-listener" start="EAGER">
            <local-cache 
                name="memcachedCache"
                start="EAGER"
                batching="false"
                indexing="NONE">
                <locking
                    isolation="REPEATABLE_READ"
                    acquire-timeout="20000"
                    concurrency-level="500"
                    striping="false" />
                <transaction mode="NONE" />
                <string-keyed-jdbc-store datasource="java:jboss/datasources/ExampleDS" passivation="false" preload="false" purge="false">
                    <property name="databaseType">H2</property>
                    <string-keyed-table prefix="JDG">
                        <id-column name="id" type="VARCHAR"/>
                        <data-column name="datum" type="BINARY"/>
                        <timestamp-column name="version" type="BIGINT"/>
                    </string-keyed-table>
                </string-keyed-jdbc-store>
            </local-cache>
            <local-cache 
                name="teams"
                start="EAGER"
                batching="false"
                indexing="NONE">
                <locking
                    isolation="REPEATABLE_READ"
                    acquire-timeout="20000"
                    concurrency-level="500"
                    striping="false" />
                <transaction mode="NONE" />
                <string-keyed-jdbc-store datasource="java:jboss/datasources/ExampleDS" passivation="false" preload="false" purge="false">
                    <property name="databaseType">H2</property>
                    <string-keyed-table prefix="JDG">
                        <id-column name="id" type="VARCHAR"/>
                        <data-column name="datum" type="BINARY"/>
                        <timestamp-column name="version" type="BIGINT"/>
                    </string-keyed-table>
                </string-keyed-jdbc-store>
            </local-cache>
        </cache-container>
    </subsystem>
    ```

Start JBoss Datagrid Server 6
------------------------------

1. Open a command line and navigate to the root of the JBoss server directory.
2. The following shows the command line to start the server with the web profile:

        For Linux:   JDG_HOME/bin/standalone.sh
        For Windows: JDG_HOME\bin\standalone.bat


Build and Run the Quickstart
-------------------------

_NOTE: The following build command assumes you have configured your Maven user settings. If you have not, you must include Maven setting arguments on the command line. See [Build and Deploy the Quickstarts](../README.md#buildanddeploy) for complete instructions and additional options._

1. Make sure you have started the JBoss Server as described above.
2. Open a command line and navigate to the root directory of this quickstart.
3. Type this command to build and deploy the archive:

        mvn clean package 
                
4. This will create a file at `target/rest-endpoint-quickstart.jar` 

5. Run the example application in its directory:

    java -jar target/rest-endpoint-quickstart.jar
 

Using the application
---------------------
Basic usage scenarios can look like this (keyboard shortcuts will be shown to you upon start):

1. add a team
2. add players to the team
3. print all teams and their players
4. remove a player from certain team
5. print again
6. remove a team
7. print again


Debug the Application
------------------------------------

Contributor: For example: 

If you want to debug the source code or look at the Javadocs of any library in the project, run either of the following commands to pull them into your local repository. The IDE should then detect them.

    mvn dependency:sources
    mvn dependency:resolve -Dclassifier=javadoc





