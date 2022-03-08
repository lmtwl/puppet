server {
    listen 80;
    server_name trade.xunyou.com orig.trade.xunyou.com;
    return 301 https://$server_name$request_uri;
    limit_req zone=one burst=15;
}
server {
    listen 443 ssl;
    limit_req zone=one burst=15;
    ssi on;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;
    ssi_types text/shtml;
    root /usr/share/nginx/trade.xunyou.com;
    index index.shtml  index.html index.php;
    server_name trade.xunyou.com orig.trade.xunyou.com;

    error_page 500 = /500.html;
    error_page 404 =404 /404.html;
    location ~ /.svn/ {
       deny all;
    }
    location ~ \.php {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
    location ~ /xystat{
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        include fastcgi_params;
    }
}
