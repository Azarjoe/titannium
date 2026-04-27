#!/bin/bash

docker exec npm sh -c 'cat > /etc/nginx/conf.d/include/proxy.conf << "EOF"
add_header X-Served-By \$host always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
proxy_set_header Host \$host;
proxy_set_header X-Forwarded-Scheme \$x_forwarded_scheme;
proxy_set_header X-Forwarded-Proto  \$x_forwarded_proto;
proxy_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
proxy_set_header X-Real-IP          \$remote_addr;
proxy_pass       \$forward_scheme://\$server:\$port\$request_uri;
EOF'

docker exec npm nginx -s reload
echo "Headers applied successfully"
