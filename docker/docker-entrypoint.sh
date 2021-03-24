#!/bin/sh
supercronic docker/crontab &\
apachectl -D FOREGROUND
