#!/usr/bin/env bash
set -o errexit

cp -rT /src/ /app/
chown -R tox:tox /app/

if [[ $1 == "test" ]] ; then
  exec gosu tox tox "$@"
else
  exec "$@"
fi