#! /usr/bin/env bash

# run the configuration script and keep running the container
exec bash /apps/config/config.sh "$@"
