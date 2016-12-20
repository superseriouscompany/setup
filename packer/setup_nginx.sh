sudo apt-get install -y nginx

# nginx config
echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

  log_format nginx '\$remote_addr - \$remote_user [\$time_local] '
                   '\"\$request\" \$status \$body_bytes_sent \$request_time '
                   '\"\$http_referer\" \"\$http_user_agent\"';

	##
	# Gzip Settings
	##

	gzip on;
	gzip_disable \"msie6\";

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
" | sudo tee /etc/nginx/nginx.conf >/dev/null

# Server config
echo "server {
    listen 80 default_server;
    server_name _;

    access_log /var/log/nginx/access.log nginx;

    location / {
            add_header Content-Type text/plain;
            return 200 'lawng';
    }

    location /nginx_status {
            stub_status on;

            access_log off;
            allow 127.0.0.1;
            deny all;
    }

}" | sudo tee /etc/nginx/sites-available/default >/dev/null

# Integrate nginx with prometheus

# HTTP BLOCK
##
# Metrics Settings
##
#
# lua_shared_dict prometheus_metrics 10M;
# lua_package_path "/home/ubuntu/nginx-lua-prometheus/?.lua";
# init_by_lua '
# 	prometheus = require("prometheus").init("prometheus_metrics")
# 		metric_requests = prometheus:counter(
# 		"nginx_http_requests_total", "Number of HTTP requests", {"host", "status"})
# 	metric_latency = prometheus:histogram(
# 		"nginx_http_request_duration_seconds", "HTTP request latency", {"host"})
# ';
#
# log_by_lua '
# 	local host = ngx.var.host:gsub("^www.", "")
# 	metric_requests:inc(1, {host, ngx.var.status})
# 	metric_latency:observe(ngx.now() - ngx.req.start_time(), {host})
# ';

# SERVER BLOCK
# location /metrics {
# content_by_lua 'prometheus:collect()';
# }
#
# location / {
# 				proxy_pass http://localhost:3000;
# }
