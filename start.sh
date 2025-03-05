#!/bin/bash
set -e

# Initialize MariaDB data directory if it hasn't been set up
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background
echo "Starting MariaDB..."
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

# Wait for MariaDB to start up (adjust sleep duration as necessary)
sleep 10

# (Optional) You could also start additional services like cron or postfix here


# starting php-fpm
mkdir -p /run/php-fpm

php-fpm -D

# Start Apache in the foreground
echo "Starting Apache..."
httpd -DFOREGROUND
