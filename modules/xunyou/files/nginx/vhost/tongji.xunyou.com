log_format  tongji  '$time_local|'
                        '$arg_i|$arg_p|$arg_u|$arg_h|$status';
server {
        listen 80;
        listen 443 ssl;
        limit_req zone=one burst=35;
        ssi on;
        ssi_types text/shtml;
        ssl_certificate /etc/nginx/ssl/xunyou.crt;
        ssl_certificate_key /etc/nginx/ssl/xunyou.key;
        ssl_session_timeout 5m;
        ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
        ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
        ssl_prefer_server_ciphers on;
        root /usr/share/nginx/tongji.xunyou.com;
        index index.php index.html index.shtml;
#        access_log_bypass_if ($status = 404);
#        access_log_bypass_if ($arg_i = '');
#        access_log_bypass_if ($arg_p = '');
#        access_log_bypass_if ($arg_u = '');
#        access_log syslog:server=127.0.0.1,facility=local7,tag=tongji_xunyou_com,severity=info tongji;
#        access_log /var/log/nginx/access.json.log tongji;

        server_name tongji.xunyou.com orig.tongji.xunyou.com;
        location ~ /.svn/ {
           deny all;
        }

        location / {
                expires 25m;
        }
        error_page 500  /500.html;
        error_page 404  /404.html;
        location ~ \.php {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_intercept_errors on;
                fastcgi_pass unix:/dev/shm/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
        }
}
