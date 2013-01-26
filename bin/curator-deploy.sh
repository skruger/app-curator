#!/bin/bash

. ~/bin/env_import

function echo_msg(){
	echo "===> $1"
}

cd $APPDIR

echo_msg "Removing virtualenv and app directories."
rm -rf $APPDIR/app $APPDIR/virtenv

echo_msg "Creating virtualenv."
virtualenv --setuptools $APPDIR/virtenv

echo_msg "Cloning application."
git clone $APPDIR/app.git $CURATOR_REPO_DIR

echo_msg "Create empty docroot if missing."
test ! -d $APPDIR/app/htdocs && mkdir $APPDIR/app/htdocs

echo_msg "Run $APPDIR/app/setup.py install"
$APPDIR/virtenv/bin/python $APPDIR/app/setup.py install

echo_msg "Create httpd/curator.conf"
cat > $APPDIR/httpd/curator.conf << EOF

ServerRoot "$APPDIR/httpd"
Listen $CURATOR_LISTEN_PORT
User $USER
Group $USER
DocumentRoot "$CURATOR_REPO_DIR/htdocs"
<Directory "$CURATOR_REPO_DIR/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
Include conf/httpd.conf

WSGIScriptAlias / $CURATOR_REPO_DIR/wsgi/curator.application
WSGIPassAuthorization On

EOF

if [ -d "$CURATOR_REPO_DIR/wsgi/static" ]; then
cat >> $APPDIR/httpd/curator.conf << EOF
Alias /static/ $CURATOR_REPO_DIR/wsgi/static/
<Directory "$CURATOR_REPO_DIR/wsgi/static/">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>

EOF
fi

echo_msg "Run $CURATOR_REPO_DIR/curator.postdeploy."
if [ -x "$CURATOR_REPO_DIR/curator.postdeploy" ]; then
	$CURATOR_REPO_DIR/curator.postdeploy
fi

