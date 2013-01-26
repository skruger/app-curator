#!/bin/bash

cd ~
APPDIR=`pwd`

rm -rf app virtenv

virtualenv --setuptools virtenv

git clone app.git

test ! -d app/htdocs && mkdir app/htdocs

virtenv/bin/python app/setup.py install

cat > httpd/curator.conf << EOF

ServerRoot "$APPDIR/httpd"
Listen 6001
User mediatraqr
Group mediatraqr
DocumentRoot "$APPDIR/app/htdocs"
<Directory "$APPDIR/app/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
Include conf/httpd.conf

WSGIScriptAlias / $APPDIR/app/wsgi/curator.application
WSGIPassAuthorization On

EOF

if [ -d "$APPDIR/app/wsgi/static" ]; then
cat >> httpd/curator.conf << EOF
Alias /static/ /home/mediatraqr/app/wsgi/static/
<Directory "/home/mediatraqr/app/wsgi/static/">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>

EOF
fi

~/virtenv/bin/python ~/app/wsgi/mediatraqr/manage.py collectstatic --noinput
