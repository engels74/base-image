# Base Image (engels74)

<p align="center">
  <img src="https://engels74.net/img/image-logos/base-image.svg" alt="base-image" style="width: 30%;"/>
</p>

<p align="center">
  <a href="https://github.com/engels74/base-image/blob/master/LICENSE"><img src="https://img.shields.io/badge/License%20(Image)-GPL--3.0-orange" alt="License (Image)"></a>
  <a href="https://hub.docker.com/r/engels74/base-image"><img src="https://img.shields.io/docker/pulls/engels74/base-image.svg" alt="Docker Pulls"></a>
  <a href="https://github.com/engels74/base-image/stargazers"><img src="https://img.shields.io/github/stars/engels74/base-image.svg" alt="GitHub Stars"></a>
</p>

## 📖 Documentation

All the documentation for the "base image" is located here.

For more information about the Docker image itself, you can visit [engels74.net](https://engels74.net/containers/base-image).

## 🐋 Docker Image

### Docker Compose

To get started with qbittorrent using Docker, follow these steps:

1. **Use this Docker Compose example**
    ```yaml
	services:
	  base-image:
	    container_name: base-image
	    image: ghcr.io/engels74/base-image:alpinevpn
	    environment:
	      - PUID=1000
	      - PGID=1000
	      - UMASK=002
	      - TZ=Etc/UTC
	    volumes:
	      - /<host_folder_config>:/config
    ```

2. **Run the Docker container using `docker compose`:**
    ```sh
    docker compose -f /choose/path/to/docker-compose.base-image.yml up -d
    ```

## 📜 License

The Docker image is licensed under the GPLv3 License. See the [LICENSE](https://github.com/engels74/base-image/blob/master/LICENSE) file for details.
