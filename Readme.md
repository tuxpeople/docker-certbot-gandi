> THIS REPOSITORY IS NOT LONGER MAINTAINED

# Docker image for Certbot plugin for authentication using Gandi LiveDNS

USE THIS AT YOUR OWN RISK! THIS IS NOT VERY GOOD TESTED!

This is the dockerized version of a plugin for [Certbot](https://certbot.eff.org/) that uses the Gandi
LiveDNS API to allow [Gandi](https://www.gandi.net/) customers to prove control of a domain name.

![Docker Build Status](https://img.shields.io/docker/build/tdeutsch/docker-certbot-gandi.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/tdeutsch/docker-certbot-gandi.svg)
![Docker Stars](https://img.shields.io/docker/stars/tdeutsch/docker-certbot-gandi.svg)
![Docker Layers](https://images.microbadger.com/badges/image/tdeutsch/docker-certbot-gandi.svg)
![Docker Version](https://images.microbadger.com/badges/version/tdeutsch/docker-certbot-gandi.svg)


## Kudos

- This image wouldnt be possible without [Yohann Leon great plugin](https://github.com/obynio/certbot-plugin-gandi)
- Philipp for his [article about nginx and certbot](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71), where I have my entrypoint line from.

## Docker hub tags

You can use following tags on Docker hub:

* `latest` - latest release

## Usage

1. Obtain a Gandi API token (see [Gandi LiveDNS API](https://doc.livedns.gandi.net/))

2. Create a `gandi.ini` config file with the following contents and apply `chmod 600 gandi.ini` on it:
   ```
   certbot_plugin_gandi:dns_api_key=APIKEY
   ```
   Replace `APIKEY` with your Gandi API key and ensure permissions are set to disallow access to other users.
3. Create a `docker-compose.yml` like this. Details are depending on your usage:
   ```
   version: "2"

   networks:
     test:
       external: false

   services:
     certbot:
       image: tdeutsch/docker-certbot-gandi
       restart: always
       volumes:
         - ./data/certbot/conf:/etc/letsencrypt
         - /path/to/gandi.ini:/gandi.ini:ro
         - /etc/localtime:/etc/localtime:ro
       entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew -a certbot-plugin-gandi:dns --certbot-plugin-gandi:dns-credentials /gandi.ini; sleep 12h & wait $${!}; done;'"
       networks:
         - test
   ```
   The customized entrypoint will periodically check if a certificate needs to be renewed. You may also add your other images which are using the certificates to the `docker-compose.yml`. As an example, to use the certificates with the official Nginx docker image, use this volume mount:
   ```
         - ./data/certbot/conf:/etc/letsencrypt
   ```
4. Before you start your docker compose, you need to get the certificate. Easiest way is probably with a additional compose file like `docker-compose-init.yml`:
   ```
   version: "2"

   services:
     certbot:
       image: tdeutsch/docker-certbot-gandi
       volumes:
         - ./data/certbot/conf:/etc/letsencrypt
         - /path/to/gandi.ini:/gandi.ini:ro
         - /etc/localtime:/etc/localtime:ro
       entrypoint: "/bin/sh -c 'certbot certonly --agree-tos -a certbot-plugin-gandi:dns --certbot-plugin-gandi:dns-credentials /gandi.ini -m YOUREMAILADRESS -d YOURDOMAIN,*.YOURDOMAIN --preferred-challenges dns-01'"
   ```
   Run it like this, which should create the certificates at the correct place:
   ```
   docker-compose -f docker-compose-init.yml up
   ```

Please note that this solution is usually not relevant if you're using Gandi's web hosting services as Gandi offers free automated certificates for all simplehosting plans having SSL in the admin interface.
