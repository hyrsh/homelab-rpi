# Containers

We have to start with containers and briefly recap what they are. To ease up understanding I use [Docker](https://www.docker.com/) to describe a basic idea of a container.

The traditional way of executing a programm you wrote (e.g. hello.exe on Windows or hello on Linux) would be in a terminal (Powershell or any TTY in Linux) with something like ./hello or .\hello.exe.

Since this is a local approach and we want to execute it on another machine the first problem we have to solve is:

- How do I get the compiled binary to another server or client?

You can package it to ZIP file or TARball and copy it via SCP, mail, SFTP, Git (and many others) to the host and then run it again it the remote terminal.

All of this is possible and sometimes it is still necessary and done. But is poses some pitfalls:

- Does the host have everything installed my binary needs?
- Is the default configuration also shipped with my binary?
- What version of my binary is running on the host?
- Is the host compatible with its OS and libraries?

To address these issues we can use a simple but powerful idea to put our binary in an isolated environment that provides everything it needs to run. It will have its own filesystem structures, packages, libraries and connectivity to the CPU, memory, network, storage.

In Linux this environment is called a container. On Windows there are no native container concepty and therefore we do not further mention this OS.

A container consists of a base structure that is able to communicate with the underlaying host. This minimal structure can be setup by the [Dockerfile](https://docs.docker.com/reference/dockerfile/) command "FROM scratch". This base of a container only provides a slim filesystem to be able to spawn the process responsible for your binary.

If you have your static compiled binary you can package it to a container image. Navigate to the directory of the binary and create a Dockerfile:

`Dockerfile`
```Dockerfile
FROM scratch
COPY ./mybinary /
CMD ["/mybinary]
```

Run the docker command for building the image:

```shell
docker build -t myimage:1.0 .
```

`Output: docker images`
```shell
REPOSITORY     TAG    IMAGE ID       CREATED         SIZE  
myimage        1.0    59c8f13c04cd   10 seconds ago  5MB
```

This image can now be uploaded to your personal DockerHub account or an alternative registry (e.g. Harbor, Artifactory, ACR, ECR, GCR). From there anyone running Docker can use that image to run your binary on their host.