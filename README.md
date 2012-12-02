This will set up an installation of wordpress on Debian and Redhat style distributions.

Installation includes software and configuration for mysql, apache httpd and php module.

__Wordpress version: 3.4.1__

__Additional software__

_Themes_
* Graphene 1.8
* Suffusion 4.2.8

_Plugins_
* Wordpress importer 0.6

__Usage__

    class {
      wordpress:
      wordpress_db_name =>      "<name of database>",
      wordpress_db_user =>      "<database user>",
      wordpress_db_password =>  "<database password>"
    }
