#!/bin/bash

service cron start
docker-php-entrypoint apache2-foreground
