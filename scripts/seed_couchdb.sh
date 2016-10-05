#!/bin/bash -e

# This script is inspired from similar scripts in the Kitura BluePic project

# Find our current directory
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Parse input parameters
database=bookshelf_db
url=http://localhost:5984

for i in "$@"
do
case $i in
    --username=*)
    username="${i#*=}"
    shift
    ;;
    --password=*)
    password="${i#*=}"
    shift
    ;;
    --url=*)
    url="${i#*=}"
    shift
    ;;
    *)
    ;;
esac
done

if [ -z $username ]; then
  echo "Usage:"
  echo "seed_couchdb.sh --username=<username> --password=<password> [--url=<url>]"
  echo "    default for --url is '$url'"
  exit
fi


# delete and create database to ensure it's empty
curl -s -X DELETE $url/$database -u $username:$password
curl -s -X PUT $url/$database -u $username:$password

# Upload design document
curl -s -X PUT "$url/$database/_design/main_design" -u $username:$password \
    -d @$current_dir/main_design.json

# Create data
curl -s -H "Content-Type: application/json" -d @$current_dir/books.json \
    -X POST $url/$database/_bulk_docs -u $username:$password

echo
echo "Finished populating couchdb database '$database' on '$url'"
