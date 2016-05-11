#!/usr/bin/env bash

set -o errexit

cp -rT /src/ /app/
chown -R tox:tox /app/

exec gosu tox tox "$@"
