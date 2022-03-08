server {
    listen 80;
#    listen 443 ssl;
    ssi on;
    ssi_types text/shtml;
#    ssl_certificate /etc/nginx/ssl/xunyou.crt;
#    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
#    ssl_session_timeout 5m;
#    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
#    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
#    ssl_prefer_server_ciphers on;
#    ssl_client_certificate /etc/nginx/ssl/root.crt;
#    ssl_verify_client on;
    root /usr/share/nginx/charge-client.xunyougz.com/;
    index index.html index.php;
    server_name charge-client.xunyougz.com orig.charge-client.xunyougz.com;
    error_page 500 /500.html;
    location ~ /.svn/ {
        deny all;
    }
    location / {
        try_files $uri /dist/index.html;
    }
    location /api {
        proxy_pass http://webserver.xunyou.com;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host webserver.xunyou.com;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

       # Following is necessary for Websocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location ~ \.php {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
