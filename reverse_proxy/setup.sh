## Install NGINX

echo "[+] Setting up NGINX"


if [ $@ != 2 ]
then
	echo "usage ./setup URL PORT"
	exit
fi

sudo apt-get install nginx -y

## Setup config for server

echo "server {
	listen 443 ssl http2;
	server_name $1;
	proxy_set_header X-Real-IP  \$remote_addr; # pass on real client IP
        proxy_set_header Upgrade \$http_upgrade;
	proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;


	location / {
        	proxy_pass https://localhost:$2;
	}
}" > /etc/nginx/sites-available/$1

ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1

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

sudo apt-get install make-ssl-cert -y
sudo make-ssl-cert generate-default-snakeoil

sudo systemctl reload nginx

## Setup TLS Cert with Certbot

echo "[+] Setting up Certbot"

sudo apt-get update

sudo apt-get install certbot python3-certbot-nginx

sudo certbot --nginx


sudo apt-get install ufw

sudo ufw enable 
sudo ufw allow http
sudo ufw allow https

