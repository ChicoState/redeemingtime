# Base and Name
FROM python AS make
LABEL name dev_env

# Install Python and Django
RUN pip install Django djangorestframework

# <Install Frontend Here>
RUN git clone https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}" #path to use flutter run
RUN flutter precache
RUN flutter doctor -v

# Use unprivileged user and copy our directory.
RUN useradd -m rtt
USER rtt
WORKDIR /home

# Run the server in the controlled environment as the default action.
CMD python3 -m manage makemigrations && python3 -m manage migrate && python3 -m manage runserver 0.0.0.0:8000 && flutter run -d web-server --web-port=8001# Add Frontend Run to This
# Use the script to run the server properly.
