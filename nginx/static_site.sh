## ensure if user is root

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ $@ != 3 ]
then
	echo "usage ./setup URL PORT ROOT"
	exit
fi

## Setup default config

echo "server {
    listen 443 ssl http2;
    server_name $1;
    proxy_set_header X-Real-IP  \$remote_addr; # pass on real client IP
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host \$host;

    location / {
        root $3;
        index index.html;
    }

}
