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
By default, docker-varnish caches a web server on the Docker host, via IP address 172.17.42.1 (the Docker gateway) on port 8080.

Start your [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image, binding host port 8080 to port 80 and with the named container of 'lamp', as follows:

    sudo docker run -d -p 8080:80 --name lamp dell/lamp

Next, start the Varnish image, binding host port 80 to port 80, with a named container of 'varnish'. This will cache the LAMP site serving on port 8080:

    sudo docker run -d -p 80:80 --name varnish dell/varnish
    
Test the deployment via the command line:

    curl http://localhost/

Alternatively, browse to:

    http://localhost/

If you inspect the container logs, you will see the output from the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

    sudo docker logs varnish

### Advanced Example

By default docker-varnish image is configured to use Docker gateway IP to cache the docker host on port 8080 with a [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) of 100MB.

This example will override these defaults using:
- **VARNISH_BACKEND_IP** to specify the IP address of the host that Varnish will cache.
- **VARNISH_BACKEND_PORT** to specify the PORT of the host that Varnish will cache.
- **VARNISH_STORAGE_AMOUNT** to set the [Varnish cache amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html).

First run the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image and then run varnish as the cache proxy for the LAMP website. 

    sudo docker run -d -p 8080:80 --name lamp dell/lamp

Now start the varnish image, this time specifying the host IP address (**VARNISH_BACKEND_IP**) and host port 8080 (**VARNISH_BACKEND_PORT**) This is the port that the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image is bound to. A cache storage amount can also be specified using (**VARNISH_STORAGE_AMOUNT**) 

```no-highlight
sudo docker run -d -p 80:80 \
-e VARNISH_BACKEND_IP=192.168.171.129 \
-e VARNISH_BACKEND_PORT=8080 \
-e VARNISH_STORAGE_AMOUNT=200M \
--name varnish dell/varnish
```

Alternatively don't specify **VARNISH_BACKEND_IP** or **VARNISH_BACKEND_PORT** as Varnish is setup to default to using the docker gateway IP to reach the host on port 8080.

    sudo docker run -d -p 80:80 -e VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish

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

Create the directory that will be mapped to Varnish:

    sudo mkdir /vconf

Create and edit a file called **config.template**:

    sudo nano /vconf/config.template

Copy the **backend default** contents below into **/vconf/config.template**.  Setting the **.host** to IP address 172.17.42.1 (the Docker gateway) and **.port** 8080 will configure Varnish to cache a website running on port 8080 on the Docker Host. 

```no-highlight
backend default {
    .host = "172.17.42.1";
    .port = "8080";
    .connect_timeout = 1s;       # Maximum of 1s for backend connection.
    .first_byte_timeout = 5s;    # Maximum of 5s for the first byte.
    .between_bytes_timeout = 2s; # Maximum of 2s between each bytes sent.
}
```

Run the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image:

    sudo docker run -d -p 8080:80 --name lamp dell/lamp

Then run varnish specifying the volume mapping so that the **config.template** that you created can be loaded in the docker-varnish container: 

    sudo docker run -d -p 80:80 -v /vconf:/etc/varnish/config --name varnish dell/varnish 

Inspect the logs and check that **"config.template detected"** is present:

    sudo docker logs varnish

Test the deployment on the CLI using:

    curl http://localhost/

Or through the browser on:

    http://localhost/

## Verify Varnish Cache is Working.

Using the docker-lamp image, simulate the processor load by forcing a delay in PHP processing.

Run the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) image, using the volume mapping to allow the PHP to be modified.

    sudo docker run -d -p 8080:80 -v /lamp-www:/var/www/html --name lamp dell/lamp

Modify the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) index.php to have a delay when querying the MySql version.

    sudo nano /lamp-www/index.php


Insert the **sleep(2);** command here (line 20):
  
    <body>
      <img id="logo" src="logo.png" />
      <h1><?php echo "Hello world!"; ?></h1>
    <?php
      sleep(2);
    
      $link = mysql_connect('localhost', 'root');
    
      if(!$link) {
    ?>


Now run Varnish:

    sudo docker run -d -p 80:80 --name varnish dell/varnish

Inspect the Varnish http header values to verify that the site is being cached:

    curl -I http://localhost

This will display output like this:

```no-highlight
HTTP/1.1 200 OK
Server: Apache/2.4.7 (Ubuntu)
X-Powered-By: PHP/5.5.9-1ubuntu4.4
Vary: Accept-Encoding
Content-Type: text/html
Date: Wed, 26 Nov 2014 16:46:14 GMT
X-Varnish: 663286749
Age: 0
Via: 1.1 varnish
Connection: keep-alive
```

Run the curl command again: 

```no-highlight
HTTP/1.1 200 OK
Server: Apache/2.4.7 (Ubuntu)
X-Powered-By: PHP/5.5.9-1ubuntu4.4
Vary: Accept-Encoding
Content-Type: text/html
Date: Wed, 26 Nov 2014 16:46:14 GMT
X-Varnish: 663286750 663286749
Age: 10
Via: 1.1 varnish
Connection: keep-alive
```

The key [varnish http fields](https://www.varnish-cache.org/docs/2.1/faq/http.html) are **X-Varnish:** which contains both the ID of the current request and the ID of the request that populated the cache and **Age:** which is the amount of time in seconds that the current cache has been served.  If the Age is 0 on the second curl command varnish is not caching or has just cached the site. 

###Test the performance of Varnish

Using the [Apache Benchmark **ab** tool](http://httpd.apache.org/docs/2.2/programs/ab.html).  Install Apache2-utils:

    sudo apt-get install apache2-utils

Benchmark the performance of the LAMP site without Varnish Caching.  This will perform and measure 100 concurrent requests up to a total of 1000 *(NOTE: This will take at least* **20s** *as we have enduced a 2s processing time per request and we are performing 100 requests in parrallel)*: 

    ab -c 100 -n 1000 http://localhost:8080/

Key output:

```no-highlight
Document Length:        430 bytes
...
Time per request:       2431.655 [ms] (mean)
Time per request:       24.317 [ms] (mean, across all concurrent requests)
```

Do the same, this time using the Varnish Cache endpoint:

    ab -c 100 -n 1000 http://localhost/

Key output:

```no-highlight
Document Length:        430 bytes
...
Time per request:       5.282 [ms] (mean)
Time per request:       0.528 [ms] (mean, across all concurrent requests)
```

The document length should be the same between tests.
Time per request through Varnish should not include the simulated processing time proving the benefits of Varnish Caching.

*PLEASE NOTE: The default cache timeout duration is 120s.  If the cache has expired (Age: 120), Then Varnish will refresh the cache with the next request. Subsequent requests for the next 120s will then be presented from the Varnish cache.*

## Reference

### Image Details

Based on | [jacksoncage/varnish](https://github.com/jacksoncage/varnish-docker)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/varnish](https://registry.hub.docker.com/u/dell/varnish) 
