# docker-varnish
This image installs [Varnish 3.0](https://www.varnish-cache.org/docs/3.0/index.html), an HTTP accelerator, also known as a "caching HTTP reverse proxy".  Varnish may be placed front of any server that speaks HTTP, to cache the contents. It typically speeds up delivery with a factor of [300 - 1000x](https://www.varnish-cache.org/about), depending on the system architecture.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
Varnish    | [3.0.5-2](https://www.varnish-cache.org/docs/3.0/index.html) | Caching HTTP Reverse Proxy

## Usage

### Basic Example
By default, docker-varnish caches a web server on the Docker host, via IP address 172.17.42.1 (the Docker gateway) on port 80.

Start a LAMP container, serving port 80, as follows:

    sudo docker run -d -p 80:80 --name lamp dell/lamp

Next, start the Varnish container, binding host port 8080 to (Varnish) container port 80, and caching the LAMP website:

    sudo docker run -d -p 8080:80 --name varnish dell/varnish
    
Test the deployment via the command line:

    curl http://localhost:8080/

Alternatively, browse to:

    http://localhost:8080/

If you inspect the container logs, you will see the output from the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example

The default [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) is 100MB.


- Set up varnish as a cache proxy for another container hosting a website.  For this example run the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image and then run varnish as the cache proxy for lamp. 

- Ports 8080 (dell/lamp Apache Web Server) and 2000 (varnish cache proxy) exposed.
- [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) 200MB

Start the dell/lamp image binding host port 8080 to port 80 (Apache Web Server) in the container:

    sudo docker run -d -p 8080:80 dell/lamp

Now start the varnish image, this time specifying the host IP address (**VARNISH_BACKEND_IP**) and host port 8080 (**VARNISH_BACKEND_PORT**) This is the port that the dell/lamp image has bound to.  

A cache storage amount can also be specified using (**VARNISH_STORAGE_AMOUNT**) 

    sudo docker run -d -p 2000:80 -e VARNISH_BACKEND_PORT=8080 -e \
    VARNISH_BACKEND_IP=192.168.171.129 -e VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish

Alternatively don't specify (**VARNISH_BACKEND_IP**) and Varnish will default to using the docker gateway IP to reach the host. The port (**VARNISH_BACKEND_PORT**) is still required to reach the exposed lamp container port 8080.

    sudo docker run -d -p 2000:80 -e VARNISH_BACKEND_PORT=8080 -e \
    VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish

Test the deployment on the CLI using:

    curl http://localhost:2000/

Or through the browser on

    http://localhost:2000/

Inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

## Reference

### Image Details

Based on | [jacksoncage/varnish](https://github.com/jacksoncage/varnish-docker)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/varnish](https://registry.hub.docker.com/u/dell/varnish) 
