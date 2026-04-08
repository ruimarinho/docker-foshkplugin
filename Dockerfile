# Use the official Python image as a parent image
FROM python:3.11-alpine

# Define arguments for PUID/PGID and FOSHKplugin version
ARG PUID=1000
ARG PGID=1000
ARG FOSHKPLUGIN_VERSION=0.0.10Beta

# Set environment variables
ENV PUID=$PUID 
ENV PGID=$PGID

# Update package list and install necessary packages
RUN apk add --no-cache wget unzip su-exec

# Set the PYTHONPATH environment variable
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages


# Set the working directory
WORKDIR /opt/foshkplugin

# Create a non-root user and group
RUN addgroup -g ${PGID} foshk && \
    adduser -D -u ${PUID} -G foshk foshk && \
    chown -R foshk:foshk /opt/foshkplugin

# Download the FOSHKplugin package
RUN wget -q -N -O generic-FOSHKplugin.zip \
    --https-only --secure-protocol=TLSv1_2 \
    https://foshkplugin.phantasoft.de/files/generic-FOSHKplugin-${FOSHKPLUGIN_VERSION}.zip && \
    unzip -o generic-FOSHKplugin.zip && \
    chmod u+x generic-FOSHKplugin-install.sh && \
    rm generic-FOSHKplugin.zip

# Install necessary Python packages
RUN pip3 install --no-cache-dir --upgrade requests paho-mqtt influxdb pillow influxdb-client

# Modify the Python script as needed
RUN sed -i 's/(200,203)/(200,205)/g' foshkplugin.py

# Create entrypoint script
RUN cat > entrypoint.sh << 'EOF'
#!/bin/sh
if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g foshk)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^foshk:\([^:]*\):[0-9]*/foshk:\1:${PGID}/" /etc/group
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u foshk)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^foshk:\([^:]*\):\([0-9]*\):[0-9]*/foshk:\1:${PUID}:\2/" /etc/passwd
fi
chown -R foshk:foshk /opt/foshkplugin

# Create logs directory
mkdir -p /opt/foshkplugin/logs
chown -R foshk:foshk /opt/foshkplugin/logs

# Start FOSHKplugin and tail both log files to stdout
su-exec foshk sh -c 'python3 foshkplugin.py &
sleep 2
tail -f /opt/foshkplugin/logs/snd-foshkplugin.log /opt/foshkplugin/logs/log-foshkplugin.log 2>/dev/null'
EOF
RUN chmod +x entrypoint.sh

# Define the entry point
ENTRYPOINT ["./entrypoint.sh"]
