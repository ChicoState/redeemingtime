# Base and Name
FROM ubuntu AS make
LABEL name dev_env_frontend

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}" # Path to use flutter run
RUN flutter precache
RUN flutter doctor -v

# Use unprivileged user and copy our directory.
RUN useradd -m rtt
USER rtt
WORKDIR /home

# Run in the controlled environment as the default action.
CMD flutter run -d web-server --web-port=8001
# Use the script to run the server properly.
