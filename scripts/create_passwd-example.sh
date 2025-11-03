#!/bin/bash

set -ex

USERS="user1@password1 user2@dafd^;:;aa user3@password3"

touch passwd.user
for user in $USERS; do
    IFS='@' read -r username password <<< "$user"
    echo "Adding user: $username with password: $password"
    htpasswd -b -B passwd.user "$username" "$password"
done