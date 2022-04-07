# Omeka-S312 in Docker containers. S312 stands for Omeka S version 3.1.2

## Launch the containers

Install Docker and Docker-compose on your host (can be a physical or virtual machine). 

Download the file "docker-compose.yml".

From the directory containing the "docker-compose.yml" file:

```
$ sudo docker-compose up -d
```

This will deploy three Docker containers:

- Container 1: mariadb (mysql) 
- Container 2: phpmyadmin (connected to container 1)
- Container 3: omeka-s312 (connected to container 1)

With your browser, go to:

- Omeka-S312: http://hostname
- PhpMyAdmin: http://hostname:8080

At that point, you can start configuring your Omeka-S web portal.

Remarks:

- images will be downloaded automatically from the Docker hub: 67911151/omeka-s312:latest, mariadb:latest, phpmyadmin:latest.
- for the omeka-s container, /var/www/html/files (media files uploaded by the users) and /var/www/html/config/database.ini (configuration file with the credentials for the db) are put in a named volume and will survive the removal of the container. The mariadb container also puts the data (omeka-s db in /var/lib/mysql) in a named volume. Volumes are hosted in the host filesystem (/var/lib/docker/volumes).

To stop the containers:

```
$ sudo docker-compose stop
```

To remove the containers:

```
$ sudo docker-compose rm 
```

Remark: this will NOT delete the volumes (omeka and mariadb). If you launch again "sudo docker-compose up -d", the volumes will be re-used.

To login into a container:

```
$ sudo docker container exec -it <container-id-or-name> bash 
```

## Build a new image (optional)

If you want to modify the omeka-s image (by changing the Dockerfile file), you will need to build a new image:

E.g.:

```
$ git clone https://github.com/spatialscientist/omeka-s312-docker.git
$ cd omeka-s312-docker
```

Edit the Dockerfile file.

Once done, build the new Docker image:

```
$ sudo docker image build -t foo/omeka-s312:1.0.1-bar .
$ sudo docker image tag foo/omeka-s:1.0.1-bar foo/omeka-s312:latest
```

Upload the image to your Docker hub repository:

Login in your account (e.g. foo) on hub.docker.com, and create a repository "omeka-s312", then upload your customized image:

```
$ sudo docker login --username=foo
$ sudo docker image push foo/omeka-s312:1.0.1-bar
$ sudo docker image push foo/omeka-s312:latest
```
