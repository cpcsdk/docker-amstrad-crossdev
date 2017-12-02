#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-1000}

# Create arnold user with the right user id
echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -u $USER_ID  -d /home/arnold -M arnold
addgroup arnold dialout
addgroup arnold audio
export HOME=/home/arnold

chown arnold $HOME -R

sudo -u arnold git config --global merge.tool meld

# Launch the command
exec /usr/local/bin/gosu arnold "$@"
