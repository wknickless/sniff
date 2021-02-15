#!/bin/bash -x
sudo docker build --no-cache . -t wknickless/netsniff-ng:latest --pull && \
      sudo docker push wknickless/netsniff-ng:latest

