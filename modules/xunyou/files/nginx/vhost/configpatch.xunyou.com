server {
        listen 80;
        listen 443 ssl;
        ssi on;
        ssi_types text/shtml;
        ssl_certificate /etc/nginx/ssl/xunyou.crt;
        ssl_certificate_key /etc/nginx/ssl/xunyou.key;
        ssl_session_timeout 5m;
        ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
        ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
        ssl_prefer_server_ciphers on;
        root /usr/share/nginx/configpatch.xunyou.com;
        index index.php index.html index.shtml;

        # Make site accessible from http://localhost/
        server_name configpatch.xunyou.com orig.configpatch.xunyou.com orig-configpatch.xunyou.com;
        location ~ /.svn/ {
           deny all;
        }

        location / {
                expires -1;
        }
        error_page 500  /500.html;
        error_page 404  /404.html;
}
