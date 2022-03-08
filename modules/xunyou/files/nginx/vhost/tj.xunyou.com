server {
    listen 80;
    server_name tj.xunyou.com orig.tj.xunyou.com orig-tj.xunyou.com;
    return 301 https://$server_name$request_uri;
    limit_req zone=one burst=15;
}
server {
    listen 443 ssl;
    limit_req zone=one burst=30;
    ssi on;
    ssi_types text/shtml;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2 TLSv1;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;
    root /usr/share/nginx/tj.xunyou.com;
    index index.php index.html index.shtml;
    server_name tj.xunyou.com orig.tj.xunyou.com orig-tj.xunyou.com;
    location ~ /.svn/ {
       deny all;
    }
    location / {
        expires 25m;
    }
    error_page 500  /500.html;
    error_page 404  /404.html;
    location ~ /log/ {
        deny all;
    }
    location ~ \.php {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
