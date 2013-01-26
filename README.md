app-curator
===========

Deployment tool for managing python apps in per-user containers.  Currently
developed against Ubuntu server and somewhat inspired by openshift.  This first
version assumes that python applications are being deployed.

Installation
------------

To create a new curator instance add a user, clone the curator repository, and run setup.

As root:

    git clone https://github.com/skruger/app-curator.git
    cd app-curator
    su <user> -c ./setup

Or as the user:

    git clone https://github.com/skruger/app-curator.git
    cd app-curator
    ./setup

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

    echo "mydbusername" > ~/env/APP_DB_USER


Deploying Applications
----------------------

To deploy a python wsgi application you need to setup a file in your repo.  The layout of this
application repository matches the openshift django examples.

<apprepo>/wsgi/curator.application
    #!/usr/bin/env python
    
    import os
    import sys
    
    os.environ['DJANGO_SETTINGS_MODULE'] = 'myapp.settings'
    sys.path.append(os.path.join(os.environ['CURATOR_REPO_DIR'], 'wsgi'))
    sys.path.append(os.path.join(os.environ['CURATOR_REPO_DIR'], 'wsgi', 'myapp'))
    virtenv = os.environ['APPDIR'] + '/virtenv/'
    os.environ['PYTHON_EGG_CACHE'] = os.path.join(virtenv, 'lib/python2.7/site-packages')
    virtualenv = os.path.join(virtenv, 'bin/activate_this.py')
    try:
        execfile(virtualenv, dict(__file__=virtualenv))
    except:
        pass
    
    import django.core.handlers.wsgi
    application = django.core.handlers.wsgi.WSGIHandler()

Once that file is created you can commit and push to the curator repo.

    git remote add curator <username>@<host>:app.git
    git push curator master


