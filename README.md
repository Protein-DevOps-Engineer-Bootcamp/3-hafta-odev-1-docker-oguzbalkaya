# Protein DevOps Engineer Bootcamp

The user wants to run the application which in app directory with docker.There are 3 modes.

#### Mode 1 : Image Build

Build an image and if registery parameter is not empty, push it to registery.

Required parameters;
- mode
- image-name
- image-tag

Optional parameters;
- registery (If you don't write, no push.)
- other (If you want to give more parameters, you can use it.)

#### Mode 2 : Deploy Image

Run an image with Docker.

Required parameters;
- mode
- image-name
- image-tag

Optional parameters;
- container-name (If you don't write, docker use random name.)
- memory (If you don't write, docker use default limit.)
- cpu (If you don't write, docker use default limit.)
- volume (If you don't write, no volume.)
- port (If you don't write, docker use random port)
- other (If you want to give more parameters, you can use it.)


#### Mode 3 : Run Template App

Run a template app with Docker Compose. There are 2 apps. They are MySQL and MongoDB.

Required parameters;
- mode
- application-name

Optional parameters;
- other (If you want to give more parameters, you can use it.)


## Files

#### /scripts/docker_dev_tools.sh
Main script file.

#### /scripts/docker_dev_tools.conf
Configuration file.It contains commands, user informations, path of files, path of log files and colors.

#### /compose_files/mongo.yaml
Docker Compose file for MongoDB

#### /compose_files/mysql.yaml
Docker Compose file for MySQL


## Usage



 `--mode <build|deploy|template>`    Select mode

 `--image-name <name>`     	     Docker image name

 `--image-tab <tag>`        	     Docker image tag
 
 `--memory <limit>`  		     Container memory limit

 `--cpu <limit>`    		     Contaimer CPU limit

 `--registery <dockerhub|gitlab>`    DockerHub or GitLab Image Registery

 `--application-name <mysql|mongo>`  Run MySQL or Mongo Server
  
 `--volume <volume>`     	     Docker volume

 `--port> <ports>`     		     Ports (like 8080:8080)

 `--other <parameters>`     	     Other parameters.If you want to use more parameters, you can write.( --other "--memory-swap=1g)

 
Show help page.

```bash
  ./docker_dev_tools.sh --help
```

Build an image.

```bash
  ./docker_dev_tools.sh --mode build --image-name name --image-tag latest
```

Build an image and push it to DockerHub.If you want to push to GitLab Registery, you need to write gitlab to registery parameter.

```bash
  ./docker_dev_tools.sh --mode build --image-name name --image-tag latest --registery dockerhub
```

Run an image with default limits and random container name.

```bash
  ./docker_dev_tools.sh --mode deploy --image-name name --image-tag latest 
```

Run an image with special limits and special container name.

```bash
  ./docker_dev_tools.sh --mode deploy --image-name name --image-tag latest --memory 1g --cpu 2 --container-name mycontainer
```

Run an image with special limit and random container name. Also we can give more parameters with --other like the example.

```bash
  ./docker_dev_tools.sh --mode deploy --image-name name --image-tag latest --memory 1g --cpu 2 --other "--memory-swap=1g --memory-reversation=750m"
```

Run an image with Docker Volume.

```bash
  ./docker_dev_tools.sh --mode deploy --image-name name --image-tag latest --memory 1g --cpu 1 --volume /home/user/data:/app
```

Run an app with docker compose.It use docker compose files which in the path written in configuration file.If you want to run mongo server, you need to write mongo to application name parameter.

```bash
  ./docker_dev_tools.sh --mode template --application-name mysql
```

## Technologies

- Linux
- Bash Scripting
- Git
- Docker


## License

[GPL3](https://www.gnu.org/licenses/gpl-3.0.html)


