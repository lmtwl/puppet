server {
    listen 80;
    ssi on;
    ssi_types text/shtml;
    root /usr/share/nginx/iuni.tyjsq.com/web/www;
    index index.shtml index.html index.php;
    server_name iuni.tyjsq.com orig.iuni.tyjsq.com;
    error_page 500 /500.html;
    #error_page 403 http://www.xunyou.com;
    error_page 404 /404.html;
    location / {
        expires 25m;
    }
    location ~ /.svn/ {
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
