- [x] Cache service: Hello World via Hot Rod.

- [x] Data Grid service: Hello World.
* Should the hello world quickstart be shared? In some kind of shared folder?
* Creating a cache service or data grid service becomes just a parameter to the tutorial.
* Less code to maintain

- [x] Custom XML: For a 2 node cluster and do a Hello World via Hot Rod.
* Custom XML deployment working, but needs verifying that cluster can form.
* Needs a basic example to check that things work.

- [x] X-Site: Hello World via Hot Rod.
* Basic tutorial in place that successfully establishes the x-site view. 
* A hello world tutorial Hot Rod tutorial needed to verify that what is stored in one site is retrieved in the other.

- [x] Accessing Cache Service or Data Grid Service unauthenticated and unencrypted
* Custom XML tutorial shows how to do this 

- [x] External access via Hot Rod for cache or data grid service.
* Show how data can be accessed externally.

- [x] External access via HTTP REST for cache or data grid service.
* Show how data can be accessed externally.
* Secured access not fully working, see [JDG-2446](https://issues.jboss.org/browse/JDG-2446)
* Temporarily working with -k (issue)

- [x] Create a new cache via Hot Rod API in cache service.
* Cache can only a copy of default configuration. 
* Show how the cache can be created permanently and show how it survives after complete restart.

- [x] Create a new cache via Hot Rod API in data grid service.
* Similar to cache service but here you can create any cache type by passing the correct XML. 
* Additionally show how cache can be created permanently.

- [ ] Persist data to persistent volume file system with data grid service.

- [ ] Persist data and index information to persistent volume file system with data grid service.

- [ ] Persist data into MySQL DB with data grid service.

- [ ] Persist data into PostgreSQL DB with data grid service.
