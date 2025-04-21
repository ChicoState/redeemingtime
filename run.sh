#!/bin/bash

# Build and Run Both Frontend And Backend
docker build -t rtt .
docker run -it -v "$(pwd):/home/rtt" -p 8000:8000 rtt
