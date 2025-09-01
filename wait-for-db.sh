#!/bin/sh
# wait-for-db.sh

set -e

host="$1"
shift
cmd="$@"

until nc -z "$host" 5432; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "Database is up - executing command"
exec $cmd
