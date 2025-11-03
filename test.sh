#!/bin/bash

# set -x
set -e


function check_url() {
    EXPECT_CODE=$1
    URL=$2
    code=$(curl "$URL" -L -o /dev/null -w '%{http_code}\n' -s) || true
    if [ "$code" != "$EXPECT_CODE" ]; then
        echo "Expected $EXPECT_CODE but got $code for $URL"
        exit 1
    else
        echo "Success: $URL returned $code"
    fi
}

function check_200() {
    check_url 200 "$@"
}
function check_403() {
    check_url 403 "$@"
}

# Function to check if a HTTPS-URL CONNECT is not allowed
function check_000() {
    check_url 000 "$@"
}

# Manager check
#curl http://localhost:3128/squid-internal-mgr/menu


################################################################################
# Don't connect to
function check_deny() {
    check_403 http://example.com/
    check_000 https://www.google.com/
}

################################################################################
# APT
# Site check(repository-apt.conf HTTP)
function check_accept() {
check_200 http://deb.debian.org/
check_200 http://archive.ubuntu.com/
check_200 http://security.ubuntu.com/ubuntu/dists/noble-security/InRelease

# Site check(repository-apt.conf HTTPS)
# / path is returned 304 to www.ubuntu.com, so we check this path
# now HTTPS repository is disabled
check_000 https://security.ubuntu.com/ubuntu/dists/noble-security/InRelease
check_000 https://esm.ubuntu.com
check_000 https://motd.ubuntu.com

# repository-postgres.conf
check_200 https://www.postgresql.org
check_200 https://apt.postgresql.org/pub/repos/apt/
# not allowed
check_000 https://wiki.postgresql.org
}

################################################################################
# Restricted sites
# github.conf
function check_restrected() {
code=$1
check_url $code https://github.com
check_url $code https://raw.githubusercontent.com/tetsuyainfra/docker-image-caching-by-squid/refs/heads/main/README.md
}


################################################################################
echo "-------------------- Without  Authentication to proxy --------------------"
http_proxy=http://localhost:3128/
https_proxy=http://localhost:3128/
export http_proxy https_proxy

check_deny
check_accept
check_restrected 000


################################################################################
echo "-------------------- With Basic Authentication to proxy --------------------"
http_proxy=http://user1:password1@localhost:3128/
https_proxy=http://user1:password1@localhost:3128/
export http_proxy https_proxy

check_deny
check_accept
check_restrected 200

echo "All tests passed."
