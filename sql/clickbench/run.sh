#!/bin/bash

TRIES=3

cat queries.sql | while read query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches

    echo "$query";
    echo '\timing' > /tmp/query_temp.sql
    for i in $(seq 1 $TRIES); do
        echo "$query" >> /tmp/query_temp.sql
    done;
    psql -d postgres -t -f /tmp/query_temp.sql | grep 'Time'
done;
