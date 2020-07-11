## ensure if user is root

echo "[+] Ensuring Root User"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ $@ != 2 ]
then
	echo "usage ./setup URL PORT"
	exit
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

ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1

echo "[+] Setting up Certbot"

apt-get update
apt-get install certbot python3-certbot-nginx
certbot --nginx

systemctl reload nginx
