## ensure if user is root

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

## install nginx

apt-update 
apt-get install nginx -y

## Setup default config

echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 301 https://$host$request_uri;
}

server {
        listen 80;
        listen [::]:80;
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
        ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
        return 403;
}" > /etc/nginx/sites-available/default

systemctl reload nginx

apt-get install make-ssl-cert -y
make-ssl-cert generate-default-snakeoil

apt-get install ufw

ufw enable 
ufw allow http
ufw allow https

