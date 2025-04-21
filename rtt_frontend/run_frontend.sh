#!/bin/bash

# Build and Run Frontend
docker build -t rtt_frontend .
docker run -it -v "$(pwd):/home/rtt_frontend" -p 8000:8000 rtt_frontend
