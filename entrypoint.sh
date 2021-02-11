#!/bin/bash

printf "Starting PHP...\n"
php-fpm --daemonize

printf "Starting Nginx...\n"
nginx -g 'daemon off;'

