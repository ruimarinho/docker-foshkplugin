# Multi-stage build: download and patch in a builder stage, ship a minimal runtime
FROM python:3.11-alpine AS builder

# Define an argument for the FOSHKplugin version
# NB: upstream updates this zip in place, so rebuild with --no-cache to pick up new builds
ARG FOSHKPLUGIN_VERSION=0.0.10Beta

# Set the working directory
WORKDIR /opt/foshkplugin

# Install download tools, fetch and extract FOSHKplugin in one layer
RUN apk add --no-cache wget unzip && \
    wget -q --https-only --secure-protocol=TLSv1_2 -O FOSHKplugin.zip \
      https://foshkplugin.phantasoft.de/files/generic-FOSHKplugin-${FOSHKPLUGIN_VERSION}.zip && \
    unzip -o FOSHKplugin.zip && \
    rm FOSHKplugin.zip && \
    chmod u+x generic-FOSHKplugin-install.sh

# Install necessary Python packages (all are hard imports of foshkplugin.py)
RUN pip3 install --no-cache-dir --upgrade requests paho-mqtt influxdb influxdb-client pillow paramiko urllib3

# Treat HTTP 203/204 forward responses as success (upstream only accepts 200-202)
RUN sed -i 's/(200,203)/(200,205)/g' foshkplugin.py

# Final image
FROM python:3.11-alpine

# Run unbuffered so log output reaches `docker logs` immediately
ENV PYTHONUNBUFFERED=1

# Create a non-root user
RUN adduser -D foshkuser

# Set the working directory
WORKDIR /opt/foshkplugin

# Copy files from the builder stage
COPY --from=builder /opt/foshkplugin /opt/foshkplugin
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Set ownership of the working directory
RUN chown -R foshkuser:foshkuser /opt/foshkplugin

# Switch to non-root user
USER foshkuser

# Set the entry point and default command
ENTRYPOINT ["python3"]
CMD ["/opt/foshkplugin/foshkplugin.py"]

# Health check example — requires LBH_PORT to be set in foshkplugin.conf (e.g. 8781)
#HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
#  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8781/FOSHKplugin/status')" || exit 1
