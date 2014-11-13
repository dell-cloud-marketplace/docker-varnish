# docker-varnish
A web application accelerator also known as a caching HTTP reverse proxy. You install it in front of any server that speaks HTTP and configure it to cache the contents. Varnish Cache is really, really fast. It typically speeds up delivery with a factor of 300 - 1000x, depending on your architecture.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
Varnish    | [3.0.5-2](https://www.varnish-cache.org/docs/3.0/index.html) | Caching HTTP Reverse Proxy

## Usage

### Basic Example
docker-varnish will default to caching a web server on the host port 80 using the default docker gateway to the host on IP 172.17.42.1 
The default cache size is 100MB.

Start your image binding host port 2000 to port 80. The docker-varnish image will default to caching your website being hosted on the docker host.

    sudo docker run -d -p 2000:80 --name varnish dell/varnish
    
Test your deployment on the CLI using:

    curl http://localhost:2000/

Or through the browser on

    http://localhost:2000/

You can also inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example
You can set up varnish as a cache proxy for another container running a website.  For this example we will run the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image and then run varnish as the cache proxy for lamp. 

Start the dell/lamp image binding host port 8080 to port 80 (Apache Web Server) in your container:

    sudo docker run -d -p 8080:80 dell/lamp

Now start the varnish image, this time specifying the IP address (**VARNISH_BACKEND_IP**) of your host and host port 8080 (**VARNISH_BACKEND_PORT**) (this is the port that the dell/lamp image has bound to.  A cache storage amount can also be specified using (**VARNISH_STORAGE_AMOUNT**)

    sudo docker run -d -p 2000:80 -e VARNISH_BACKEND_PORT=8080 -e VARNISH_BACKEND_IP=192.168.171.129 \ 
    -e VARNISH_STORAGE_AMOUNT=200M dell/varnish

Test your deployment on the CLI using:

    curl http://localhost:2000/

Or through the browser on

    http://localhost:2000/

You can also inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

## Reference

### Image Details

Based on  

Pre-built Imag
