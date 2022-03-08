server {
    listen 80;
    server_name rank.xunyou.com orig.rank.xunyou.com;
    return 301 https://$server_name$request_uri;
    limit_req zone=one burst=15;
}
server {
    listen 443;
    ssi on;
    ssi_types text/shtml;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;
    root /usr/share/nginx/rank.xunyou.com;
    index index.html index.php;
    server_name rank.xunyou.com orig.rank.xunyou.com;
    error_page 500 /500.html;
    location ~ /.svn/ {
       deny all;
    }
    location ~ /(rank)/{
        location ~ \.(php|php5)$ {
            deny all;
        }
    }
    location ~ /(compiled)/ {
        deny all;
    }
    location ~ \.php {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
#   location ~ \.php {
#       fastcgi_split_path_info ^(.+\.php)(/.+)$;
#       fastcgi_pass unix:/dev/shm/php5-fpm.sock;
#       fastcgi_index index.php;
#   }
}
