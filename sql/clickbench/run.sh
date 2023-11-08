#!/bin/bash

TRIES=3

cat queries.sql | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches

    echo "$query";
    echo '\timing on' > /tmp/query_temp.sql
    for i in $(seq 1 $TRIES); do
        echo "$query" >> /tmp/query_temp.sql
    done;
    psql -d postgres -t -f /tmp/query_temp.sql | grep 'Time'
done;
