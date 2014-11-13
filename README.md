# docker-varnish
This installs [Varnish 3.0](https://www.varnish-cache.org/docs/3.0/index.html) which is web application accelerator also known as a caching HTTP reverse proxy. It is installed it in front of any server that speaks HTTP and configure it to cache the contents.  It makes web sites go faster.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
Varnish    | [3.0.5-2](https://www.varnish-cache.org/docs/3.0/index.html) | Caching HTTP Reverse Proxy

## Usage

### Basic Example
docker-varnish will default to caching a web server on the host port 80 using the default docker gateway to the host on IP 172.17.42.1   *[NOTE: A web site running on the docker host port 80 is required for this basic example.]*

The default [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) is 100MB.

Start the image binding host port 2000 to port 80. The docker-varnish image will default to caching the website being hosted on the docker host.

    sudo docker run -d -p 2000:80 --name varnish dell/varnish
    
Test the deployment on the CLI using:

    curl http://localhost:2000/

Or through the browser on

    http://localhost:2000/

Inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example
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
