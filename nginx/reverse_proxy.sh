#!/bin/bash
## ensure if user is root


if [[ $# -ne 2 ]]; then
	echo "usage ./setup HOST PORT"
	exit
fi

echo "[+] Ensuring Root User"

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

echo "[+] Setting up Site Config"

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
}" >> /etc/nginx/sites-available/$1 

if [ $? -ne 0 ]; then
	echo "[+] Config creation failed!"
	exit
fi

ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1 

if [ $? -ne 0 ]; then
	echo "[+] Sym Link failed!"
	exit
fi

echo "[+] Setting up Certbot"

certbot --nginx

systemctl reload nginx
