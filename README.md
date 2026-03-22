# Docker container : docker-milimovideo 

A Docker container with Milimovideo installed

## Requirements
### Docker
Docker installed and running

## Content of this repository

### Directory and Files

| Directory/file       | Description |
|---------------|----------------------|
| files | All files adding in this container                |
| Dockerfile      | Container building file               |
| README.md      | This file                |

## Used Variables
Some variables are used to build this container

| Variable | Description | Default value |
|---------------|----------------------|---------------|
| SERVER_HOST | fqdn of backend server | localhost |

## Run this container

    docker volume create milimo-data
    docker run -d --name milimovideo -e SERVER_HOST=milimo.mydomain.local -v milimo-data:/usr/share/milimovideo milimovideo:latest

## Dependencies

None.

## License
None

