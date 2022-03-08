server {
        listen 80;


        ssi on;
        ssi_types text/shtml;


        root /usr/share/nginx/apl.xunyou.com;
        index index.shtml index.html index.php;
        server_name apl.xunyou.com orig.apl.xunyou.com;

        error_page 500 /500.html;
        #error_page 403 http://www.xunyou.com;
        error_page 404 /404.html;
location ~ /.svn/ {
  deny all;
}
location ~ /(wap/uploads|uploads|api/application/cache|api/application/logs|wap/applicaiton/cache|wap/application/logs)/ {
       location ~ \.(php|php5)$ {
        deny all;
    }
}
location / {
        expires 20m;
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
  fastcgi_param SCRIPT_FILENAME /usr/share/nginx/apl.xunyou.com/$real_script_name;
  fastcgi_param SCRIPT_NAME $real_script_name;
  fastcgi_param PATH_INFO $path_info;
}

}

