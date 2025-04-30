# Base and Name
FROM python AS make
LABEL name dev_env

# Install Python and Django
RUN pip install Django djangorestframework

# Use unprivileged user and copy our directory.
RUN useradd -m rtt_backend
USER rtt_backend
WORKDIR /home/rtt_backend

# Run the server in the controlled environment as the default action.
CMD python3 -m manage makemigrations && python3 -m manage migrate && python3 -m manage runserver 0.0.0.0:8000
# Use run.sh to run the server properly.


