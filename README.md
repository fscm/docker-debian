# Debian Linux for Docker

A small Debian Linux base image designed for use in containers.

All non-required packages were removed to create this small image. When using
this image you may have to install some of the packages that usually are
installed on a regular Debian Linux image.

## Supported tags

- `jessie`
- `stretch`
- `buster`, `latest`

## What is Debian?

> Debian is a free operating system (OS) for your computer. An operating system is the set of basic programs and utilities that make your computer run.

*from* [debian.org](https://www.debian.org)

## Getting Started

There are a couple of things needed for the script to work.

### Prerequisites

Docker, either the Community Edition (CE) or Enterprise Edition (EE), needs to
be installed on your local computer.

#### Docker

Docker installation instructions can be found
[here](https://docs.docker.com/install/).

### Usage

To start a container with this image and run a shell use the following
command (the container will be deleted after exiting the shell):

```
docker container run --rm --interactive --tty fscm/debian bash
```

## Build

Build instructions can be found
[here](https://github.com/fscm/docker-debian/blob/master/README.build.md).

## Versioning

This project uses [SemVer](http://semver.org/) for versioning. For the versions
available, see the [tags on this repository](https://github.com/fscm/docker-debian/tags).

## Authors

* **Frederico Martins** - [fscm](https://github.com/fscm)

See also the list of [contributors](https://github.com/fscm/docker-debian/contributors)
who participated in this project.
