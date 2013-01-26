#!/bin/bash

. ~/bin/env_import

cd $APPDIR

rm -rf $APPDIR/app $APPDIR/virtenv

virtualenv --setuptools $APPDIR/virtenv

git clone $APPDIR/app.git $CURATOR_REPO_DIR

test ! -d $APPDIR/app/htdocs && mkdir $APPDIR/app/htdocs

$APPDIR/virtenv/bin/python $APPDIR/app/setup.py install

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

$APPDIR/virtenv/bin/python $CURATOR_REPO_DIR/wsgi/mediatraqr/manage.py collectstatic --noinput
