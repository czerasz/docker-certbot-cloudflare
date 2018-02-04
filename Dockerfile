FROM certbot/certbot:v0.21.1

RUN pip install certbot-dns-cloudflare

# Add "create or renew" Let's Encrypt certificate script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/bin/sh"]
CMD ["-c", ". /usr/local/bin/entrypoint.sh"]
