#!/bin/sh -x

while :
do
 HOME=/root speedtest --accept-license --server-id=35180 --interface=connectify0 --format=json-pretty | \
   curl --insecure --silent --show-error --data-binary "@-" --header "Content-Type: application/json" -u 'admin:admin' https://10.49.10.227:9200/speedtest-`date +%Y`/_doc || true
 sleep 900
 HOME=/root speedtest --accept-license --server-id=35180 --interface=ziply --format=json-pretty | \
   curl --insecure --silent --show-error --data-binary "@-" --header "Content-Type: application/json" -u 'admin:admin' https://10.49.10.227:9200/speedtest-`date +%Y`/_doc || true
 sleep 900
 HOME=/root speedtest --accept-license --server-id=35180 --interface=spectrum --format=json-pretty | \
   curl --insecure --silent --show-error --data-binary "@-" --header "Content-Type: application/json" -u 'admin:admin' https://10.49.10.227:9200/speedtest-`date +%Y`/_doc || true
 sleep 900
 HOME=/root speedtest --accept-license --server-id=35180 --interface=starlink --format=json-pretty | \
   curl --insecure --silent --show-error --data-binary "@-" --header "Content-Type: application/json" -u 'admin:admin' https://10.49.10.227:9200/speedtest-`date +%Y`/_doc || true
 sleep 900
done

