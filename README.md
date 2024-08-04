# FOSHKplugin docker image

## Overview

This repository provides a Docker image for [FOSHKplugin](https://foshkplugin.phantasoft.de/), a plugin that superpowers weather station data collection and integration. This Docker image ensures easy deployment and management of the FOSHKplugin application with minimal setup.

## Features

- **Easy Deployment:** Quickly set up FOSHKplugin using Docker.
- **Lightweight:** Built on the official `python:3.11-slim` image for efficient use of resources.
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
   docker run -d --name foshkplugin -v /path/to/config:/opt/foshkplugin/config -e LBPCONFIG=/opt/foshkplugin/config ghcr.io/ruimarinho/foshkplugin
   ```

   - Replace `/path/to/config` with the path to your local configuration directory.

### Usage

The container will automatically run the FOSHKplugin application. You can configure the plugin by editing the configuration files in your local directory, which is mounted inside the container.

#### docker-compose

```yaml
services:
  foshkplugin:
    image: ghcr.io/ruimarinho/foshkplugin
    ports:
      - 8780:8780/udp
      - 8781:8781
    volumes:
      - ./foshkplugin.conf:/opt/foshkplugin/foshkplugin.conf
      - ./logs:/opt/foshkplugin/logs
    environment:
      - LBPCONFIG=/opt/foshkplugin/config
```

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
