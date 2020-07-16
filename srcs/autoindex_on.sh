#!/bin/bash

cp /var/www/mkristie/autoindex/nginx.conf /etc/nginx/sites-available/mkristie
service nginx restart
echo "autoindex on"
