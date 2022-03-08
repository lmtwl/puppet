server {
    listen 80;
    server_name corp.xunyou.com orig.corp.xunyou.com;
    return 301 https://$server_name$request_uri;
    limit_req zone=one burst=15;
}
server {
    listen 443 ssl;
    ssi on;
    ssi_types text/shtml;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;
    root /usr/share/nginx/corp.xunyou.com;
    index index.shtml index.php index.html;
    server_name corp.xunyou.com orig.corp.xunyou.com;
    limit_req zone=one burst=15;
    location / {
        expires 20m;
    }
    error_page 500 /500.html;
    error_page 404 /404.php;
    location ~ /.svn/ {
        deny all;
    }
    location ~ /(application/cache)/ {
        deny all;
    }
    location ~ /(application/templates_c)/ {
        deny all;
    }
    location ~ \.php {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/dev/shm/php5-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    }
}
