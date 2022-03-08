server {
        listen  80;
        server_name manage.xunyou.com orig.manage.xunyou.com;
        rewrite ^(.*)$  https://$host$1 permanent;
	limit_req zone=one burst=15;
}
server {
        listen 443;
        ssi on;
        ssi_types text/shtml;
        root /usr/share/nginx/manage.xunyou.com/htdocs;
	limit_req zone=one burst=15;
	ssl_certificate /etc/nginx/ssl/xunyou.crt;
        ssl_certificate_key /etc/nginx/ssl/xunyou.key;
        ssl_session_timeout 5m;
        ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
        ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
        ssl_prefer_server_ciphers on;
        index index.html index.php;
        server_name manage.xunyou.com orig.manage.xunyou.com;

        #location / {
        #       try_files $uri $uri/ /index.html;
        #}

        error_page 500 /500.html;
        #error_page 404 =200  /404.php;
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
        #       fastcgi_intercept_errors on;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/dev/shm/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
        }

}
