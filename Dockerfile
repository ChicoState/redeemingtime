# Base and Name
FROM python AS make
LABEL name dev_env

# Install Python and Django
RUN pip install Django djangorestframework

# <Install Frontend Here>

# Use unprivileged user and copy our directory.
RUN useradd -m rtt
USER rtt
WORKDIR /home

# Run the server in the controlled environment as the default action.
CMD python3 -m manage makemigrations && python3 -m manage migrate && python3 -m manage runserver 0.0.0.0:8000 # Add Frontend Run to This

# Use the script to run the server properly.


