#!/bin/bash -x
sudo docker build . -t wknickless/netsniff-ng:latest --pull && \
      sudo docker push wknickless/netsniff-ng:latest

