# Docker Certbot Cron Image with Cloudflare integration

## Environment Variables

- `DNS_CLOUDFLARE_EMAIL` (required, default: not defined) - Cloudflare email
- `DNS_CLOUDFLARE_API_KEY` (required, default: not defined) - Cloudflare API key
- `DNS_CLOUDFLARE_CREDENTIALS` (default: `/etc/letsencrypt/cloudflare.ini`) - Cloudflare credentials INI file
- `EMAIL` (default: not defined) - doesn't work if `CONFIGURATION_FILE` was specified
- `DOMAINS` (default: not defined) - doesn't work if `CONFIGURATION_FILE` was specified
- `CONFIGURATION_FILE` (default: `/etc/letsencrypt/cli.ini`)
- `TEST` (default: not defined) - if `TEST` is set then the `staging` Let's Encrypt environment is used
- `DEBUG` (default: not defined) - if `DEBUG` is set to `true` then logs are more verbose

## Usage

```
docker run --rm --name=letsencrypt \
           -v $PWD/etc/letsencrypt/:/etc/letsencrypt/ \
           -e DNS_CLOUDFLARE_EMAIL=admin@example.com \
           -e DNS_CLOUDFLARE_API_KEY=09w1...0kc4 \
           -e DOMAINS=test.example.com \
           -e EMAIL=admin@example.com \
           czerasz/certbot-cloudflare
```

## Resources

- [Use certbot with Cloudflare](https://community.letsencrypt.org/t/tutorial-certbot-cloudflare-dns-with-apache-web-servers-on-ubuntu-16-10/38847/4)
