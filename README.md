# FOSHKplugin docker image

## Overview

This repository provides a Docker image for [FOSHKplugin](https://foshkplugin.phantasoft.de/), a plugin that superpowers weather station data collection and integration. This Docker image ensures easy deployment and management of the FOSHKplugin application with minimal setup.

## Features

- **Easy Deployment:** Quickly set up FOSHKplugin using Docker.
- **Lightweight:** Multi-stage build on the official `python:3.11-alpine` image, running as a non-root user.
- **Flexible:** Easily configurable with environment variables and command-line options.

## Getting Started

### Prerequisites

- Docker installed on your machine. You can download it from [Docker's official site](https://www.docker.com/products/docker-desktop).

### Installation

1. **Pull the Docker image from the GitHub Package Registry:**

   ```bash
   docker pull ghcr.io/ruimarinho/foshkplugin
   ```

2. **Run the Docker container:**

   ```bash
   docker run -d --name foshkplugin \
     -p 8780:8780/udp -p 8781:8781 \
     -v /path/to/foshkplugin.conf:/opt/foshkplugin/foshkplugin.conf \
     -v /path/to/logs:/opt/foshkplugin/logs \
     ghcr.io/ruimarinho/foshkplugin
   ```

   - The plugin reads its configuration from `/opt/foshkplugin/foshkplugin.conf`, so bind-mount your config file directly over that path.
   - The published ports must match the `LBU_PORT` (UDP) and `LBH_PORT` (HTTP) values in your `foshkplugin.conf`.
   - The container runs as a non-root user (uid 1000). Make sure the mounted config file and logs directory are writable by uid 1000 — the plugin updates its `[Status]` section on shutdown and writes logs continuously.

### Usage

The container will automatically run the FOSHKplugin application. You can configure the plugin by editing the mounted `foshkplugin.conf` file and restarting the container.

#### docker-compose

```yaml
services:
  foshkplugin:
    image: ghcr.io/ruimarinho/foshkplugin
    ports:
      - 8780:8780/udp # LBU_PORT
      - 8781:8781 # LBH_PORT
    volumes:
      - ./foshkplugin.conf:/opt/foshkplugin/foshkplugin.conf
      - ./logs:/opt/foshkplugin/logs
    healthcheck:
      test: ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8781/FOSHKplugin/status')"]
      interval: 30s
      timeout: 10s
      start_period: 15s
      retries: 3
```

The healthcheck probes the plugin's status endpoint and requires `LBH_PORT = 8781` in your `foshkplugin.conf`; adjust or remove it if you use a different port.

## Building the Image Locally

If you prefer to build the Docker image yourself, clone this repository and use the following command:

```bash
git clone https://github.com/ruimarinho/docker-foshkplugin.git
cd docker-foshkplugin
docker build -t ghcr.io/ruimarinho/foshkplugin .
```

## Contributing

We welcome contributions! Please feel free to submit issues or pull requests to improve the Docker image or documentation.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. For more information on the FOSHKplugin license, please visit the [project's website](https://wiki.loxberry.de/plugins/foshkplugin/start).

## Contact

For questions or support, please open an issue in the [GitHub repository](https://github.com/ruimarinho/docker-foshkplugin/issues).
