# docker-varnish
This image installs [Varnish 3.0](https://www.varnish-cache.org/docs/3.0/index.html), an HTTP accelerator, also known as a "caching HTTP reverse proxy".  Varnish may be placed front of any server that speaks HTTP, to cache the contents. It typically speeds up delivery with a factor of [300 - 1000x](https://www.varnish-cache.org/about), depending on the system architecture.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------
Ubuntu     | Trusty     | Operating system
Varnish    | 3.0.5-2    | Caching HTTP Reverse Proxy

## Default Settings
By default, a docker-varnish container caches IP address 172.17.42.1 (the Docker gateway) on port 8080. This means that it is readily testable using another container, such as [dell/lamp](https://github.com/dell-cloud-marketplace/docker-lamp), on the same host.

Setting                | Value       | Description
-----------------------|-------------|------------
VARNISH_BACKEND_IP     | 172.17.42.1 | The IP address of the host to be cached
VARNISH_BACKEND_PORT   | 8080        | The port of the host to be cached
VARNISH_STORAGE_AMOUNT | 100MB       | The Varnish [cache] (https://www.varnish-cache.org/docs/3.0/tutorial/sizing_your_cache.html) size

## Usage
We can illustrate how Varnish works in 4 steps (experienced users may wish to skip to section [Advanced Usage](#advanced-usage)), on the Docker host:

1. Start a LAMP container
2. Start a Varnish container
3. Verify caching
4. Test the performance

### Step 1. Start a LAMP Container
Start a LAMP container on the Docker host, with:

- Host port 8080 bound to container port 80 (Apache Web Server)
- A data volume, which provides access to the LAMP application files, in folder **/app** on the host

As follows:

```no-highlight
sudo docker run -d -p 8080:80 -v /app:/var/www/html --name lamp dell/lamp
```

### Step 2. Start a Varnish Container
Start a Varnish container on the Docker host, with host port 80 mapped to container port 80:

```no-highlight
sudo docker run -d -p 80:80 --name varnish dell/varnish
```

*Note that the Varnish container defaults for VARNISH_BACKEND_IP and VARNISH_BACKEND_PORT map to the LAMP container created in the previous step.*

### Step 3. Verify Caching

#### i: Get the Homepage Headers
Get the headers for the LAMP homepage:

```no-highlight
curl -I http://localhost
```

This should display the Varnish HTTP headers, indicating that the request is being cached:

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

#### ii: Check the Logs
Inspect the container logs to see the output from the [varnishlog](https://www.varnish-cache.org/docs/3.0/tutorial/logging.html) utility:

```no-highlight
sudo docker logs varnish
```

#### iii: Get the Homepage Headers
Again, get the homepage headers:

```no-highlight
curl -I http://localhost
```

The output should be similar to the following:

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

The key header [fields](https://www.varnish-cache.org/docs/2.1/faq/http.html) are

- **X-Varnish** which contains both the ID of the current request and the ID of the request that populated the cache and;
- **Age** which is the amount of time in seconds that the current cache has been served.  If the Age is 0, Varnish is not caching or has just cached the request.

### Step 4. Test the Performance
In our test, we simulate CPU load via a 2 second delay in the PHP code which queries the MySQL version.

First, edit **/app/index.php** (the LAMP homepage):

```no-highlight
sudo vi /app/index.php 
```

Insert a **sleep(2)** statement, near line 20:
  
```php
<?php
  sleep(2);

  $link = mysql_connect('localhost', 'root');

  if(!$link) {
?><
```

Next, install apache2-utils, which includes the Apache [ab](http://httpd.apache.org/docs/2.2/programs/ab.html) benchmarking tool:

```no-highlight
sudo apt-get install apache2-utils
```

#### A. Benchmark without Caching
Start 100 concurrent requests, up to a total of 1000, directly against the LAMP container:

```no-highlight
ab -c 100 -n 1000 http://localhost:8080/
```

Example output:

```no-highlight
Document Length:        430 bytes
...
Time per request:       2431.655 [ms] (mean)
Time per request:       24.317 [ms] (mean, across all concurrent requests)
```

As shown, this took over 20 seconds (20 = **sleep time** * **total requests** / **concurrent requests**).

#### B. Benchmark with Caching
Test the Varnish endpoint:

```no-highlight
ab -c 100 -n 1000 http://localhost/
```

Example output:

```no-highlight
Document Length:        430 bytes
...
Time per request:       5.282 [ms] (mean)
Time per request:       0.528 [ms] (mean, across all concurrent requests)
```

As shown, the **time per request** is, on average, 0.24% of the previous (uncached) value. This is because it does not necessarily include the simulated processing time.

*Please note that the default cache timeout duration is 120s.  If the cache has expired (Age: 120), Varnish will refresh the cache with the next request.*

<a name="advanced-usage"></a>
## Advanced Usage

### Overriding the Defaults
The following parameters may be provided to override the Varnish defaults:

- **VARNISH_BACKEND_IP** - defaults to 172.17.42.1 (the Docker gateway)
- **VARNISH_BACKEND_PORT** - defaults to 8080
- **VARNISH_STORAGE_AMOUNT** - defaults to 100MB

For example:

```no-highlight
sudo docker run -d -p 80:80 \
    -e VARNISH_BACKEND_IP=192.168.171.129 \
    -e VARNISH_BACKEND_PORT=8000 \
    -e VARNISH_STORAGE_AMOUNT=200M \
    --name varnish dell/varnish
```

### Loading a Varnish Configuration File
A Varnish configuration file may be specified using [VCL](https://www.varnish-cache.org/docs/3.0/reference/vcl.html), a small Varnish-specific language.

To do so, create a file named **config.template**, with the required VCL content, in a folder on the host (e.g. **/vconf**). As shown below, the VCL can reference environmental variables:

```
...
backend default {
    .host = "${VARNISH_BACKEND_IP}";
    .port = "${VARNISH_BACKEND_PORT}";
}
...
```

Next, start the Varnish container, with the host directory (e.g. **/vconf**) mapped to folder **/etc/varnish/config** in the container:

```no-highlight
sudo docker run -d -p 80:80 -v /vconf:/etc/varnish/config \
    --name varnish dell/varnish 
```

Inspect the host folder (e.g. **/vconf**) and check that file **config.vcl** is present, with the expected content.

## Reference

### Image Details

Based on | [jacksoncage/varnish](https://github.com/jacksoncage/varnish-docker)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/varnish](https://registry.hub.docker.com/u/dell/varnish) 
