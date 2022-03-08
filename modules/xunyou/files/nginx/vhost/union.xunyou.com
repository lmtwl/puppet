server {
    listen 80;
    listen 443 ssl;
    ssi on;
    ssi_types text/shtml;
    root /usr/share/nginx/union.xunyou.com;
    index index.shtml index.html index.php;
    server_name union.xunyou.com  partnerunion.xunyou.com orig.union.xunyou.com orig.partnerunion.xunyou.com;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;

    error_page 500 /500.html;
    #error_page 403 http://www.xunyou.com;
    error_page 404 /404.html;

    location / {
        expires 25m;
    }

    location ~ /.svn/ {
        deny all;
    }
    location ~ /(pay/application/cache)/ {
        deny all;
    }
    location ~ /log/{
        location ~ \.(php|php5)$ {
            deny all;
        }
    }

    location ~ \.php {
        fastcgi_index index.php;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        include fastcgi_params;
        set $path_info "";
        set $real_script_name $fastcgi_script_name;
        if ($fastcgi_script_name ~ "^(.+?\.php)(/.+)$") {
            set $real_script_name $1;
            set $path_info $2;
        }
        fastcgi_param SCRIPT_FILENAME /usr/share/nginx/union.xunyou.com/$real_script_name;
        fastcgi_param SCRIPT_NAME $real_script_name;
        fastcgi_param PATH_INFO $path_info;
    }

}
