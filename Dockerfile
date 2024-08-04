# Use the official Python image as a parent image
FROM python:3.11-alpine

# Define an argument for the FOSHKplugin version
ARG FOSHKPLUGIN_VERSION=0.0.10Beta

# Set environment variables for non-interactive apt-get installs
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages
RUN apk add --no-cache build-base wget unzip

# Set the PYTHONPATH environment variable
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

# Set the working directory
WORKDIR /opt/foshkplugin

# Download the FOSHKplugin package
RUN wget -q -N -O generic-FOSHKplugin.zip \
    --https-only --secure-protocol=TLSv1_2 \
    https://foshkplugin.phantasoft.de/files/generic-FOSHKplugin-${FOSHKPLUGIN_VERSION}.zip && \
    unzip -o generic-FOSHKplugin.zip && \
    chmod u+x generic-FOSHKplugin-install.sh && \
    rm generic-FOSHKplugin.zip

# Install necessary Python packages
RUN pip3 install --no-cache-dir --upgrade requests paho-mqtt influxdb pillow influxdb-client

RUN apk del --no-cache build-base

# Modify the Python script as needed
RUN sed -i 's/(200,203)/(200,205)/g' foshkplugin.py

# Create a non-root user
RUN adduser -S -D -H foshkuser

# Set ownership of the working directory
RUN chown -R foshkuser:nobody /opt/foshkplugin

# Switch to non-root user
USER foshkuser

# Define the entry point and default command
ENTRYPOINT ["python3"]
CMD ["foshkplugin.py"]
