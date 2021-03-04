FROM certbot/certbot:v1.13.0

# Install the DNS plugin
RUN pip install --constraint /opt/certbot/docker_constraints.txt --no-cache-dir certbot-plugin-gandi
