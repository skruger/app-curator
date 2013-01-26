app-curator
===========

Deployment tool for managing python apps in per-user containers.  Currently
developed against Ubuntu server and somewhat inspired by openshift.  This first
version assumes that python applications are being deployed.

Installation
------------

To create a new curator instance add a user, clone the curator repository, and run setup.

As root:

> # git clone https://github.com/skruger/app-curator.git
> # cd app-curator
> # su <user> -c ./setup

Or as the user:

> $ git clone https://github.com/skruger/app-curator.git
> $ cd app-curator
> $ ./setup

What gets installed?
--------------------

When you run setup scripts are installed in ~/bin and a RHEL style Apache configuration
is installed in ~/httpd.  Some basic environment definitions are set in ~/env.

Configuring the Environment
---------------------------

The environment definitions in ~/env are exported prior to apache starting and are available
to applications as environment variables.  In python they can be found in os.environ.

To set new variables simply write a file in ~/env with the name of the variable that contains
the value of the variable.  If I wanted to set the variable APP_DB_USER=mydbusername I would
do the following:

> echo "mydbusername" > ~/env/APP_DB_USER



