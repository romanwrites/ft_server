#!/bin/bash

cp /var/www/mkristie/autoindex/nginx_autoindex_off.conf /etc/nginx/sites-available/mkristie
service nginx restart
echo "autoindex off"
