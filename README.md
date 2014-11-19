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

Start a LAMP container, serving port 8080, as follows:

    sudo docker run -d -p 8080:80 --name lamp dell/lamp

Next, start the Varnish container, binding host port 80 to (Varnish) container port 80, and caching the LAMP website:

    sudo docker run -d -p 80:80 --name varnish dell/varnish
    
Test the deployment via the command line:

    curl http://localhost/

Alternatively, browse to:

    http://localhost/

If you inspect the container logs, you will see the output from the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example

By default docker-varnish is configured to use Docker gateway IP to cache the docker host on port 8080 with a [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) of 100MB.

This example will override these defaults using:
- **VARNISH_BACKEND_IP** to specify the IP address of the host that Varnish will cache.
- **VARNISH_BACKEND_PORT** to specify the PORT of the host that Varnish will cache.
- **VARNISH_STORAGE_AMOUNT** to set the [Varnish cache amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html).

First run the [dell/wordpress](https://github.com/dell-cloud-marketplace/docker-wordpress) image and then run varnish as the cache proxy for WordPress. 

    sudo docker run -d -p 8080:80 dell/wordpress

Now start the varnish image, this time specifying the host IP address (**VARNISH_BACKEND_IP**) and host port 8080 (**VARNISH_BACKEND_PORT**) This is the port that the dell/lamp image has bound to.  

A cache storage amount can also be specified using (**VARNISH_STORAGE_AMOUNT**) 

    sudo docker run -d -p 80:80 -e VARNISH_BACKEND_IP=192.168.171.129 \
    -e VARNISH_BACKEND_PORT=8080 -e VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish

Alternatively don't specify **VARNISH_BACKEND_IP** or **VARNISH_BACKEND_PORT** and Varnish will default to using the docker gateway IP to reach the host on port 8080.

    sudo docker run -d -p 80:80 VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish

Test the deployment on the CLI using:

    curl http://localhost/

Or through the browser on

    http://localhost/

Inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example 2

A [Varnish configuration file](https://www.varnish-cache.org/docs/3.0/reference/vcl.html) can be created using VCL.  The VCL language is a small domain-specific language designed to be used to define request handling and document caching policies for Varnish Cache.

A Varnish configuration can be loaded through a file in a docker volume.  This example will use a configuration file to specify the IP and Port of the host that Varnish is to cache. 

A configuration file called **config.template** needs to be created and exist in the docker host volume directory before launching the docker-varnish container.  

Copy the [default.template](https://github.com/dell-cloud-marketplace/docker-varnish/blob/master/default.template) to create the config.template file. Then modify the backend default .host and .port parameters to explicity specify the IP address and port of the host that Varnish will cache:

    backend default {
        .host = "192.168.171.12";
        .port = "8080";
        .connect_timeout = 1s;       # Maximum of 1s for backend connection.
        .first_byte_timeout = 5s;    # Maximum of 5s for the first byte.
        .between_bytes_timeout = 2s; # Maximum of 2s between each bytes sent.
    }

Run the [dell/wordpress](https://github.com/dell-cloud-marketplace/docker-wordpress) image:

    sudo docker run -d -p 8080:80 dell/wordpress

Then run varnish specifying the volume mapping so that the **config.template** that you created can be loaded in the docker-varnish container: 

    sudo docker run -d -p 8080:80 -v /app:/etc/varnish/config --name varnish dell/varnish 

## Reference

### Image Details

Based on | [jacksoncage/varnish](https://github.com/jacksoncage/varnish-docker)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/varnish](https://registry.hub.docker.com/u/dell/varnish) 
