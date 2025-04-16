#!/bin/bash

# Build and Run Backend
docker build -t rtt_backend ./rtt_backend
docker run -it -v "$(pwd):/home/rtt_backend" -p 8000:8000 rtt_backend

# Build and Run Frontend
flutter run ./rtt_frontend
