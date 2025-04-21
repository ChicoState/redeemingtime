#!/bin/bash

# Build and Run Backend
docker build -t rtt_backend .
docker run -it -v "$(pwd):/home/rtt_backend" -p 8000:8000 rtt_backend
