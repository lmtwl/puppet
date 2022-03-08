server {
        limit_req zone=one burst=15;
        listen 80;
        ssi on;
        ssi_types text/shtml;
        root /usr/share/nginx/union.xunyou.com/qqinfo;
        index index.shtml index.html index.php;
        server_name qqvip.xunyou.com orig.qqivp.xunyou.com;

        error_page 500 /500.html;
        error_page 403 http://www.xunyou.com;
        error_page 404 /404.html;
    location ~ /.svn/ {
        deny all;
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
    fastcgi_param SCRIPT_FILENAME /usr/share/nginx/union.xunyou.com/qqinfo/$real_script_name;
    fastcgi_param SCRIPT_NAME $real_script_name;
    fastcgi_param PATH_INFO $path_info;
    }
}

