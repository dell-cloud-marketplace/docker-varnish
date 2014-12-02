# docker-varnish
This image installs [Varnish 3.0](https://www.varnish-cache.org/docs/3.0/index.html), an HTTP accelerator, also known as a "caching HTTP reverse proxy".  Varnish may be placed front of any server that speaks HTTP, to cache the contents. It typically speeds up delivery with a factor of [300 - 1000x](https://www.varnish-cache.org/about), depending on the system architecture.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
Varnish    | 3.0.5-2    | Caching HTTP Reverse Proxy

## Usage

### 1. Start the Container

#### A. Basic Usage

By default, docker-varnish caches a web server on the Docker host, via IP address 172.17.42.1 (the Docker gateway) on port 8080.

Start the Lamp container with:

- A named container (**lamp**)
- Host port 8080 mapped to port LAMP port 80 (Apache Web Server)

Do:

```no-highlight
sudo docker run -d -p 8080:80 --name lamp dell/lamp
```

Next, start the Varnish container:

- A named container of (**varnish**)
- Host port 80 mapped to varnish port 80
- This will cache the LAMP container Web Server on host port 8080

Do:

```no-highlight
sudo docker run -d -p 80:80 --name varnish dell/varnish
```
    
Test the deployment via the command line.

Do:

```no-highlight
curl http://localhost/
```

Alternatively, browse to:

```no-highlight
http://localhost/
```    

If you inspect the container logs, you will see the output from the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

```no-highlight
sudo docker logs varnish
```

#### B. Advanced Usage 1

By default docker-varnish image is configured to use Docker gateway IP to cache the docker host on port 8080 with a [Varnish cache storage amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) of 100MB.

This example will override these defaults using:
- **VARNISH_BACKEND_IP** to specify the IP address of the host that Varnish will cache.
- **VARNISH_BACKEND_PORT** to specify the PORT of the host that Varnish will cache.
- **VARNISH_STORAGE_AMOUNT** to set the [Varnish cache amount](https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html).


Start the LAMP container with:

- A named container (**lamp**)
- Host port 8080 to port LAMP port 80 (Apache Web Server)

Do:

```no-highlight
sudo docker run -d -p 8080:80 --name lamp dell/lamp
```

Next, start the Varnish container with:

- A named container (**varnish**)
- Docker Lamp Host IP address (**VARNISH_BACKEND_IP**)
- Docker Lamp Host port 8080 (**VARNISH_BACKEND_PORT**)
- A cache storage amount of 200 Mega Bytes (**VARNISH_STORAGE_AMOUNT**)

Do:

```no-highlight
sudo docker run -d -p 80:80 \
-e VARNISH_BACKEND_IP=192.168.171.129 \
-e VARNISH_BACKEND_PORT=8080 \
-e VARNISH_STORAGE_AMOUNT=200M \
--name varnish dell/varnish
```

Alternatively don't specify **VARNISH_BACKEND_IP** or **VARNISH_BACKEND_PORT** as Varnish is setup to default to using the docker gateway IP to reach the host on port 8080.

Do:

```no-highlight
sudo docker run -d -p 80:80 -e VARNISH_STORAGE_AMOUNT=200M --name varnish dell/varnish
```

Test the deployment via the command line.

Do:

```no-highlight
curl http://localhost/
```

Or through the browser on:

```no-highlight
http://localhost/
```

Inspect the logs as the container is running the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility

```no-highlight
sudo docker logs varnish
```

#### C. Advanced Usage 2

A [Varnish configuration file](https://www.varnish-cache.org/docs/3.0/reference/vcl.html) can be created using VCL.  The VCL language is a small domain-specific language designed to be used to define request handling and document caching policies for Varnish Cache.

A Varnish configuration can be loaded through a file in a docker volume.  This example will use a configuration file to specify the IP and Port of the host that Varnish is to cache. 

A configuration file called **config.template** needs to be created and exist in the docker host volume directory before launching the docker-varnish container.  

Create the directory that will be mapped to Varnish.

Do:

```no-highlight
sudo mkdir /vconf
```

Create and edit a file called **config.template**.

Do:

```no-highlight
sudo nano /vconf/config.template
```

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

Start the LAMP container with:

- A named container (**lamp**)
- Host port 8080 mapped to port LAMP port 80 (Apache Web Server)

Do:

```no-highlight
sudo docker run -d -p 8080:80 --name lamp dell/lamp
```


Next, start the Varnish container:

- A named container (**varnish**)
- Host port 80 mapped to varnish port 80
- A Volume Mapping host directory */vconf* to Varnish container directory */etc/varnish/config*
- The **config.template** that you created will be loaded in the docker-varnish container

Do:

```no-highlight
sudo docker run -d -p 80:80 -v /vconf:/etc/varnish/config --name varnish dell/varnish 
```

Inspect the logs and check that **"config.template detected"** is present:

```no-highlight
sudo docker logs varnish
```

Test the deployment via the command line.

Do:

```no-highlight
curl http://localhost/
```

Or through the browser on:

```no-highlight
http://localhost/
```

### 2. Verify Varnish Cache is Working.

Using the docker-lamp image, simulate the processor load by forcing a delay in PHP processing by modifying the LAMP PHP code through a Docker Volume.

Start the LAMP container with:

- A named container (**lamp**)
- binding host port 8080 to port LAMP port 80 (Apache Web Server)
- A Volume Mapping host directory */lamp-www* to LAMP container directory */var/www/html* 

Do:

```no-highlight
sudo docker run -d -p 8080:80 -v /lamp-www:/var/www/html --name lamp dell/lamp
```

Modify the [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp) index.php to have a delay when querying the MySql version.

```no-highlight
sudo nano /lamp-www/index.php
```

Insert the **sleep(2);** command here (line 20):
  
```no-highlight
<body>
  <img id="logo" src="logo.png" />
  <h1><?php echo "Hello world!"; ?></h1>
<?php
  sleep(2);

  $link = mysql_connect('localhost', 'root');

  if(!$link) {
?>
```

Next, start the Varnish container with:

- A named container of (**varnish**)
- Host port 80 mapped to Varnish port 80
- This will cache the LAMP container Web Server on host port 8080

Do:

```no-highlight
sudo docker run -d -p 80:80 --name varnish dell/varnish
```

Inspect the Varnish http header values to verify that the site is being cached.

Do:

```no-highlight
curl -I http://localhost
```

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

Inspect the Varnish http header values a few seconds later.

Do:

```no-highlight
curl -I http://localhost
```

This will display more output like this:

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

### 3. Test the Performance of Varnish

Using the [Apache Benchmark **ab** tool](http://httpd.apache.org/docs/2.2/programs/ab.html).  Install Apache2-utils.

Do:

```no-highlight
sudo apt-get install apache2-utils
```

Benchmark the performance of the LAMP site without Varnish Caching.  This will perform and measure 100 concurrent requests up to a total of 1000 *(NOTE: This will take at least* **20s** *as we have enduced a 2s processing time per request and we are performing 100 requests in parrallel)*.

Do:

```no-highlight
ab -c 100 -n 1000 http://localhost:8080/
```

Key output:

```no-highlight
Document Length:        430 bytes
...
Time per request:       2431.655 [ms] (mean)
Time per request:       24.317 [ms] (mean, across all concurrent requests)
```

Next test the Varnish Cache endpoint.

Do:

```no-highlight
ab -c 100 -n 1000 http://localhost/
```

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
