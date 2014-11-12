# docker-varnish
A web application accelerator also known as a caching HTTP reverse proxy. You install it in front of any server that speaks HTTP and configure it to cache the contents. Varnish Cache is really, really fast. It typically speeds up delivery with a factor of 300 - 1000x, depending on your architecture.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
Varnish    | 3.0.5-2    | Caching HTTP Reverse Proxy


## Usage

### Basic Example
Start your image binding host port 2000 to port 80.  The docker-varnish image will default to caching your website being hosted on the docker host.  There needs to be a webserver running on port 80 on the host.

    sudo docker run -d -p 2000:80 -e dell/varnish
    
Test your deployment:

    curl http://localhost:2000/


### Advanced Example
TBD:  caching for a host in another container...


## Administration



## Reference

### Image Details

Based on  

Pre-built Imag
