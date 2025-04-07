# Nginx Mini Image

![Build Status](https://github.com/Bumeranghc/nginx-mini/actions/workflows/docker-image.yaml/badge.svg?branch=main)

This repository contains a Dockerfile for building a minimal Nginx image with custom configurations and static content. The image is designed to run as a rootless user and includes gzip compression, CORS headers for static assets, and a custom MIME types configuration.

The built image is available at [Docker Hub](https://hub.docker.com/r/bumeranghc/nginx-mini).

## Features

- Builds and installs Nginx from source using Ubuntu environment.
- Configured to run as a rootless user (`nginx_user`).
- Includes gzip compression for JavaScript files.
- Adds CORS headers for static assets (e.g., `.js`, `.css`, `.woff`).
- Custom MIME types configuration.
- Logs are symlinked to `/dev/stdout` and `/dev/stderr` for Docker logging.
- Exposes port `8080`.

## File Structure

- **Dockerfile**: Defines the build process for the Nginx image.
- **nginx.conf**: Custom Nginx configuration file.
- **mime.types**: MIME types configuration for Nginx.
- **index.html**: Default static HTML file served by Nginx.

## Build and Run

### Prerequisites

- Docker installed on your system.

### Build the Image

Run the following command to build the Docker image:

```sh
docker build -t nginx-mini .
```

## Build Arguments

The Dockerfile supports the following build arguments:

- **`VERSION`**: Specifies the Nginx version to build. Default: `1.24.0`.
- **`PATCH`**: Specifies the patch version for the Nginx source. Default: `2ubuntu7.3`.
- **`TIMEZONE`**: Sets the timezone for the container. Default: `Asia/Jerusalem`.

You can override these arguments during the build process using the `--build-arg` flag. For example:

```sh
docker build -t nginx-mini \
    --build-arg VERSION=1.25.0 \
    --build-arg PATCH=2ubuntu8.1 \
    --build-arg TIMEZONE=America/New_York .
```

### Run the Container
Run the container using the following command:

```sh
docker run -p 8080:8080 nginx-mini
```

This will expose the Nginx server on port 8080.

### Access the Application
Open your browser and navigate to http://localhost:8080 to view the default static page.

## Configuration Details

### Nginx Configuration
The Nginx configuration is defined in nginx.conf. Key features include:
- Gzip compression for JavaScript files.
- CORS headers for static assets.
- Default root directory: /home/nginx_user/nginx/html/.

### MIME Types
The MIME types are defined in mime.types and include support for common file types like `.html`, `.css`, `.js`, `.woff`, and more.

### Static Content
The default static content is served from `/home/nginx_user/nginx/html/`. The `index.html` file is included as the default page.

### License
This project is licensed under the MIT License.

## Author
Pavel Semchenko