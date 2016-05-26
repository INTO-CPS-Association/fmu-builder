#!/bin/bash

cd $(dirname $0)

PIDFILE=uwsgi.pid

# the default signal for kill is TERM, which causes uWSGI to "reload"
kill -INT $(cat $PIDFILE)

rm $PIDFILE
