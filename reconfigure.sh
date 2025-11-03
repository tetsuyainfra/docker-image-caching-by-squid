#!/bin/bash

set -x

docker compose exec squid /usr/sbin/squid -k reconfigure