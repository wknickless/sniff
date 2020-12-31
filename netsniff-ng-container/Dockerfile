FROM ubuntu:latest
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends netsniff-ng && \
    rm -rf /var/lib/apt/lists/*
   
