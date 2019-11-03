#!/bin/bash

set -e                                      # Break and exit script on error
set -o nounset                              # Treat unset variables as an error

# Output errors in the log file
LOG_FILE="/var/log/startup-script.log"
touch $LOG_FILE
exec 2>> $LOG_FILE


echo '######################### STARTUP SCRIPT STARTED ########################' >> $LOG_FILE

echo 'Install packages' >> $LOG_FILE
apt-get update
apt-get install -y nginx

# Install Stackdriver Monitoring Agent
curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh
bash install-monitoring-agent.sh
service stackdriver-agent restart

# Install Stackdriver Logging Agent
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh

# fluentd config for startup script
FILE="/etc/google-fluentd/config.d/startup-script.conf"

cat << EOM > $FILE
<source>
  @type tail
  format none
  path /var/log/startup-script.log
  pos_file /var/lib/google-fluentd/pos/startup-script.pos
  read_from_head true
  tag startup-script
</source>
EOM

# fluentd config for nginx port 80
FILE="/etc/google-fluentd/config.d/nginx80.conf"

/bin/cat <<EOM >$FILE
<source>
  @type tail
  format nginx
  path /var/log/nginx/access.log
  pos_file /var/lib/google-fluentd/pos/nginx-access.pos
  read_from_head true
  tag nginx-access80
</source>
EOM

# fluentd config for nginx port 443
FILE="/etc/google-fluentd/config.d/nginx443.conf"

/bin/cat <<EOM >$FILE
<source>
  @type tail
  format nginx
  path /var/log/nginx/access443.log
  pos_file /var/lib/google-fluentd/pos/nginx-access443.pos
  read_from_head true
  tag nginx-access443
</source>
EOM

# reload stackdriver logging agent
service google-fluentd restart


#Command 'gsutil' is available in '/snap/bin/gsutil'
export PATH=$PATH:/snap/bin

echo 'Import Metadata' >> $LOG_FILE
PROJECT_METADATA="http://metadata.google.internal/computeMetadata/v1/project"
INSTANCE_METADATA="http://metadata.google.internal/computeMetadata/v1/instance"
#HOSTNAME=$(curl -s ${INSTANCE_METADATA}/name -H "Metadata-Flavor: Google")
PRIVATE_IP=$(curl -sf -H 'Metadata-Flavor:Google' http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip | tr -d '\n')
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`
SECRETS_BUCKET=$(curl -s ${INSTANCE_METADATA}/attributes/secrets-bucket -H "Metadata-Flavor: Google")
DOMAIN_NAME=$(curl -s ${INSTANCE_METADATA}/attributes/domain-name -H "Metadata-Flavor: Google")

echo 'Copy NGINX certs' >> $LOG_FILE
mkdir /etc/nginx/pki
#gsutil cp gs://$SECRETS_BUCKET/certs/certificate.crt /etc/nginx/pki/${DOMAIN_NAME}.crt
gsutil cp gs://$SECRETS_BUCKET/certs/ca_bundle.crt /etc/nginx/pki/${DOMAIN_NAME}.crt
gsutil cp gs://$SECRETS_BUCKET/certs/private.key /etc/nginx/pki/${DOMAIN_NAME}.key

#echo '--------- Disable NGINX default config' >> $LOG_FILE
#unlink /etc/nginx/sites-enabled/default

echo '--------- Copy over NGINX config' >> $LOG_FILE
gsutil cp gs://$SECRETS_BUCKET/nginx.conf /etc/nginx/sites-available/${DOMAIN_NAME}.conf

echo '--------- Change placeholders inside NGINX conf' >> $LOG_FILE
sed -i "s|DOMAIN_NAME|$DOMAIN_NAME|g" /etc/nginx/sites-available/${DOMAIN_NAME}.conf

echo '--------- Activate NGINX configs' >> $LOG_FILE
ln -s /etc/nginx/sites-available/${DOMAIN_NAME}.conf /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf

echo --------- Populate welcome and status page >> $LOG_FILE
echo Welcome to $HOSTNAME at $PRIVATE_IP in $REGION >/var/www/html/index.html
echo Welcome to $HOSTNAME at $PRIVATE_IP in $REGION >/var/www/html/status

echo '--------- Restart NGINX' >> $LOG_FILE
systemctl restart nginx


echo '######################### STARTUP SCRIPT FINISHED ########################' >> $LOG_FILE
exit 0