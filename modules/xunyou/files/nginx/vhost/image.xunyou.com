server {
    listen    80;
    listen 443 ssl;
    ssi on;
    ssi_types text/shtml;
    ssl_certificate /etc/nginx/ssl/image.xunyou.crt;
    ssl_certificate_key /etc/nginx/ssl/image.xunyou.key;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
    ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!LOW:!aNULL:!eNULL;
    ssl_prefer_server_ciphers on;

    server_name image.xunyou.com orig.image.xunyou.com;
    location / {
        root /data/www/source.xunyou.com/other;
        expires 25m;
#       proxy_pass http://xunyou2.oss-cn-qingdao.aliyuncs.com;

    }

    #location ~* ^/.well-known/pki-validation {
    #       root /data/www/source.xunyou.com/other;

    #}

}
