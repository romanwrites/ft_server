# Install the base image
FROM debian:buster

# Creating and setiing working directory so that the following commands will be run in the context of this location.
WORKDIR /

# Update package list https://www.debian.org/distrib/packages
RUN apt-get update

# Upgrade system to get more security and bug fixes
# The `y` flag assumes "Yes" to all prompts.
RUN apt-get -y upgrade
RUN apt-get -y install tree vim

# NGINX
RUN apt-get -y install nginx

# MARIADB
RUN apt-get -y install mariadb-server

# PHP set of extentions to communicate with MariaDB
RUN apt-get -y install php-fpm php-mysql

# PHP additional set of extentions to use with Wordpress
RUN apt-get -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

# WORDPRESS. chown = change owner
RUN apt-get -y install wget
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzvf latest.tar.gz
RUN mkdir var/www/mkristie
RUN mv wordpress/ /var/www/mkristie/wordpress
COPY srcs/wp-config.php /var/www/mkristie/wordpress
RUN chown -R www-data:www-data /var/www/mkristie/wordpress
RUN find /var/www/mkristie/wordpress/ -type d -exec chmod 775 {} +
RUN find /var/www/mkristie/wordpress/ -type f -exec chmod 664 {} +
RUN chmod 660 /var/www/mkristie/wordpress/wp-config.php

# PHPMYADMIN
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
RUN tar -xzvf phpMyAdmin-5.0.2-english.tar.gz
RUN mv phpMyAdmin-5.0.2-english/ /var/www/mkristie/phpmyadmin
COPY /srcs/config.inc.php /var/www/mkristie/phpmyadmin

#NGINX
COPY ./srcs/nginx.conf /etc/nginx/sites-available/mkristie
RUN ln -s /etc/nginx/sites-available/mkristie /etc/nginx/sites-enabled/
RUN mkdir /var/www/mkristie/autoindex
COPY ./srcs/nginx.conf /var/www/mkristie/autoindex
COPY ./srcs/nginx_autoindex_off.conf /var/www/mkristie/autoindex
COPY ./srcs/autoindex_on.sh .
COPY ./srcs/autoindex_off.sh .
COPY ./srcs/start_script.sh .

# SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-subj "/C=ru/ST=Moscow/L=Moscow/O=no/OU=no/CN=mkristie/" \
	-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

# Creating database
RUN service mysql start \
    && mysql -u root \
	&& mysql --execute="CREATE DATABASE wp_base; \
						GRANT ALL PRIVILEGES ON wp_base.* TO 'root'@'localhost'; \
						FLUSH PRIVILEGES; \
						UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user='root';"

# Expose port 80 for HTTP and 443 for HTTPS. So container listens these ports.
EXPOSE 80 443

# Is to tell the container which command it should run when it is started
CMD bash start_script.sh
