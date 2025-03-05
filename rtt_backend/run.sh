#!/bin/bash
docker build -t dockerfile .
docker run -it -v "$(pwd):/home/rtt_backend" -p 8000:8000 dockerfile
