server {
        server_name xunyou.com;
        rewrite ^ http://www.xunyou.com$request_uri;
}

#server {
#        listen 80 default;
#        server_name _;
#        rewrite ^ http://www.xunyou.com$request_uri;
#}
server {
	listen 80 default;
	server_name _;
	return 444;
}
