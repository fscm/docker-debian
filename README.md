# Debian Linux for Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/fscm/debian.svg?color=black&logo=docker&logoColor=white&style=flat-square)](https://hub.docker.com/r/fscm/debian)
[![Docker Stars](https://img.shields.io/docker/stars/fscm/debian.svg?color=black&logo=docker&logoColor=white&style=flat-square)](https://hub.docker.com/r/fscm/debian)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/fscm/debian.svg?color=black&logo=docker&logoColor=white&style=flat-square)](https://hub.docker.com/r/fscm/debian)

A small Debian Linux base image designed for use in containers.

All non-required packages were removed to create this small image. When using
this image you may have to install some of the packages that usually are
installed on a regular Debian Linux image.

## Supported tags

- `8.7.1`
- `8.9.0`, `jessie`
- `9.0.0`
- `9.1.0`
- `9.2.1`
- `9.3.0`
- `9.4.0`
- `9.5.0`
- `9.6.0`
- `9.8.0`
- `9.9.0`, `stretch`
- `10.0.0`, `buster`, `latest`

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
$ docker run --rm -i -t fscm/debian bash
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
