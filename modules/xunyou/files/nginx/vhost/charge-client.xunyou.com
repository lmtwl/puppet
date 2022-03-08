server {
#   listen 80;
    listen 443 ssl;
    ssi on;
    ssi_types text/shtml;
    ssl_certificate /etc/nginx/ssl/xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;
#    ssl_client_certificate /etc/nginx/ssl/root.crt;
#    ssl_verify_client on;
    root /usr/share/nginx/charge-client.xunyou.com/web/www;
    index index.html index.php;
    server_name charge-client.xunyou.com orig.charge-client.xunyou.com;
    error_page 500 /500.html;
    location ~ /.svn/ {
        deny all;
    }
    location / {
        try_files $uri /index.php$is_args$args;
        index index.php;
    }
    location = /xcharge/ {
        rewrite .* /xcharge/dist/index.html last;
    }
    location /xcharge {
        if (!-e $request_filename) {
                rewrite ^/xcharge/(.*)$ /xcharge/dist/index.html last;
            }
    }
    location ~ \.php {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/dev/shm/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
