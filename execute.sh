#!/bin/bash

echo "cleaning data"

tb datasource truncate --yes ds_visits
tb datasource truncate --yes ds_origins
tb datasource truncate --yes ds_visits_origins
tb datasource truncate --yes ds_origins_stats

old_dt=$(date '+%Y/%m/%d %H:%M:%S')
echo "$old_dt,'user-00','ES'" > /tmp/origin_first.csv

sleep 1;

dt=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt,'user-00','es-ES'" > /tmp/tmp.csv
echo " -> Inserting a visit for user-00 on $dt"
tb datasource append ds_visits /tmp/tmp.csv 1>/dev/null
tb sql "select * from visits_joined"


echo ''
read -n 1 -p "-> Inserting now the origin for user-00 that arrives late $old_dt (press enter to continue)"
tb datasource append ds_origins /tmp/origin_first.csv 1>/dev/null
tb sql "select * from visits_joined"
echo '* The country is updated with the old information'

echo ''
read -n 1 -p '-> Inserting now a new origin for user-01 (press enter)'
dt=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt,'user-01','UK'" > /tmp/tmp.csv
tb datasource append ds_origins /tmp/tmp.csv 1>/dev/null
tb sql "select * from visits_joined"
echo "* It does not add any new visits because the actual visit didn't arrive"

echo ''
read -n 1 -p '-> And now the visit for user-01 that arrives after the origin we just inserted (press enter)'

dt=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt,'user-01','en-US'" > /tmp/tmp.csv
tb datasource append ds_visits /tmp/tmp.csv 1>/dev/null
tb sql "select * from visits_joined"
echo "* It shows two visits with the right country/locale"
