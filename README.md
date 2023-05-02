# Taskflow-docker

This repository contains the necessary files to dockerise Taskflow, an Odoo based ERP system. With these files, you can easily run Taskflow in a Docker container, making it easy to install and manage during development.

# Installation

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

# Usage
Once the Docker containers are up and running, you can access Taskflow by opening a web browser and navigating to `http://localhost:8069`.

## Stopping the containers
You can stop the Docker containers by running the following command in the repository root:

```
docker-compose down
```

> Note: This command will delete all data created in the database. **Stop and restart** the Odoo container if a restart is required.

## Accessing the Shell
To access the Odoo shell, run the following command:

```
docker exec -it odoo12 bash -c "odoo shell -d localhost --db_host db --db_password odoo"
```

## Accessing the file system

```
docker exec -it odoo12 /bin/bash
```

>Note: The docker image uses the nightly build. The Odoo source code can be found in here: 
>
>```
>cd /usr/lib/python3/dist-packages/odoo
>```

## Stopping & restarting Odoo:

```
docker stop odoo12
docker start odoo12
```

>Attach to the terminal output
>
>```
>docker start -a odoo12
>```

## Installing/Updating a module via the command line
Edit the command line in the `docker-compose.yml` file to set the command that will be executed when Odoo is started.

```
  odoo:
    image: taskflow-odoo:12
    container_name: odoo12
    depends_on:
      - db
    ports:
      - "8069:8069"
    volumes:
      - ./odoo.conf:/etc/odoo/odoo.conf
    command: odoo -i web_flow,crm -d localhost <-- Edit this line
```

Run the following command to update the instance:

```
docker compose up
```

## Building the docker containers
The following repositories must be present in your working directory:

- taskflow-config
- taskflow

Once the above repositories have been cloned to your working directory, the structure should be as follows:

```
  > {WORKING_DIRECTORY}
    > taskflow
    > taskflow-config
    > taskflow-docker
```

To build the Postgres and Odoo container, run the following command from your working directory:

```
docker build -t taskflow-odoo:12 -f ./taskflow-docker/12.0/Dockerfile .
```
