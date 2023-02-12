# Taskflow-docker

This repository contains the necessary files to dockerise Taskflow, an Odoo based ERP system. With these files, you can easily run Taskflow in a Docker container, making it easy to install and manage.

## Installation

1. Install Docker:
  - On Windows:
    - You can install Docker Desktop for Windows from [here](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
    - If you are using Windows Subsystem for Linux (WSL), you can follow the installation instructions [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-on-ubuntu)
  - On Linux:
    - You can follow the installation instructions for your distro [here](https://docs.docker.com/engine/install/)

2. Clone the repository: 

```
git clone https://github.com/<your-github-username>/docker-taskflow.git
```

3. Set up your Odoo configuration:

  - Open the `odoo.conf` file located in the repository root and set the configuration options for your Taskflow installation.

4. Start the Docker containers:

```
cd docker-taskflow
docker-compose up
```

## Usage
Once the Docker containers are up and running, you can access Taskflow by opening a web browser and navigating to `http://localhost:8069`.

## Stopping the containers
You can stop the Docker containers by running the following command in the repository root:

```
docker-compose down
```

## Accessing the Shell
To access the Odoo shell, run the following command:

```
docker exec -it odoo12 bash -c "odoo shell"
```

## Stopping & restarting Odoo:

```
docker stop odoo12
docker start -a odoo12
```

