#!/bin/bash

if [ ! -z "$DNS_CLOUDFLARE_EMAIL" ] && [ ! -z "$DNS_CLOUDFLARE_API_KEY" ]; then
  cat <<EOF | sed 's/^\s*//' > /etc/letsencrypt/cloudflare.ini
  dns_cloudflare_email = ${DNS_CLOUDFLARE_EMAIL}
  dns_cloudflare_api_key = ${DNS_CLOUDFLARE_API_KEY}
EOF
  chmod 400 /etc/letsencrypt/cloudflare.ini
else
  echo "[ERROR] Both DNS_CLOUDFLARE_EMAIL and DNS_CLOUDFLARE_API_KEY environment variables are required"
  exit 1
fi

# Define letsencrypt configuration file
# Allow the user to overwrite the configuration_file variable
if [ -z "$CONFIGURATION_FILE" ]; then
  if [ -z "$EMAIL" ] || [ -z "$DOMAINS" ]; then
    # No $EMAIL, $DOMAINS variables defined - assume the configuration file was mounted
    configuration_file='/etc/letsencrypt/cli.ini'
  else
    # Customize name in case of multiple certbot cron containers running at the same time
    configuration_file="/etc/letsencrypt/cli-${EMAIL}-${DOMAINS}.ini"
  fi
else
  configuration_file="${CONFIGURATION_FILE}"
fi

# Allow the user to overwrite the configuration_file variable
if [ -z "$CONFIGURATION_FILE" ] && [ ! -z "$EMAIL" ] && [ ! -z "$DOMAINS" ]; then
  # Create configuration file if both variables are defined

  # Define letsencrypt configuration file
  # Customize name in case of multiple certbot cron containers running at the same time
  configuration_file="/etc/letsencrypt/cli-${EMAIL}-${DOMAINS}.ini"

  cat <<EOF | sed 's/^\s*//' > $configuration_file
  # Use a 4096 bit RSA key instead of 2048
  rsa-key-size = 4096
  # Register with the specified e-mail address
  email = $EMAIL
  # Get certificate for the following domains
  domains = $DOMAINS
  # Allways accept the terms of service
  agree-tos = True
  # If certificate exists renew it
  # renew-by-default = True

  # Always use the staging/testing server - avoids rate limiting
  # server = https://acme-staging.api.letsencrypt.org/directory
EOF
fi

echo -e "\n\n\n[INFO] create or renew certificate"
echo "[INFO] `date`"

if [ ! -z "$DEBUG" ] && [ "$DEBUG" == "true" ]; then
  echo "[DEBUG] Environment variables:"
  echo "[DEBUG] \$configuration_file: ${configuration_file}"
  echo "[DEBUG] \$EMAIL: ${EMAIL}"
  echo "[DEBUG] \$DOMAINS: ${DOMAINS}"
  echo "[DEBUG] \$DEBUG: ${DEBUG}"
  echo "[DEBUG] \$TEST: ${TEST}"
fi

if [ ! -f $configuration_file ]; then
  echo "[ERROR] configuration file does not exist: ${configuration_file}"
  exit 1
fi

# Create or renew certificate
if [ -z "$TEST" ]; then
  certbot certonly -n \
                   --config "${configuration_file}" \
                   --dns-cloudflare \
                   --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini
else
  certbot certonly --test-cert -n \
                   --config "${configuration_file}" \
                   --dns-cloudflare \
                   --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini
fi

# Cleanup
rm /etc/letsencrypt/cloudflare.ini

# Print Letsencrypt logs
if [ ! -z "$DEBUG" ] && [ "$DEBUG" == "true" ] && [ -f /var/log/letsencrypt/letsencrypt.log ]; then
  echo "[DEBUG] Logs from /var/log/letsencrypt/letsencrypt.log:"
  cat /var/log/letsencrypt/letsencrypt.log
fi
