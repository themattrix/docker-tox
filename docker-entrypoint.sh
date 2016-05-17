#!/usr/bin/env bash

set -o errexit

# Copy everything except dot directories from /src/ to /app/. A notable dot
# directory is '.tox', which we definitely don't want to copy into /app/,
# since it would stomp the one already there. Other dot directories may
# include virtual environments or other machine-specific configurations.
find /src -mindepth 1 -maxdepth 1 \( -type d -name ".*" -prune \) -o -exec cp -r --target-directory=/app -- {} +

# Tox will be run by the "tox" user, so it should own /app/.
chown -R tox:tox /app/

if [[ "${1}" == "tox" ]]; then
    # If the first argument was "tox" (which is the default), run tox
    # with the "tox" user, passing the remaining arguments right along.
    exec gosu tox "$@"
fi

# If the first argument was not "tox", run whichever command was given.
exec "$@"
