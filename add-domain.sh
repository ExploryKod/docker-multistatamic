#!/bin/bash

# Script to add a new domain to the Statamic multisite setup

if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain> [site-number]"
    echo "Example: $0 mysite.local 3"
    exit 1
fi

DOMAIN=$1
SITE_NUMBER=${2:-3}
SITE_NAME="site${SITE_NUMBER}"

echo "🌐 Adding domain: $DOMAIN for $SITE_NAME"

# Add domain to /etc/hosts
echo "127.0.0.1 $DOMAIN www.$DOMAIN" | sudo tee -a /etc/hosts
echo "✅ Domain added to /etc/hosts"

# Create Nginx configuration
cat > "nginx/conf.d/${DOMAIN}.conf" << EOF
# $SITE_NAME Configuration
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    root /var/www/sites/$SITE_NAME/public;
    index index.php index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Handle Statamic requests
    location / {
        try_files \$uri \$uri/ @statamic;
    }

    location @statamic {
        fastcgi_pass statamic-app-$SITE_NUMBER;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
        include fastcgi_params;
        fastcgi_param HTTP_X_FORWARDED_FOR \$proxy_add_x_forwarded_for;
        fastcgi_param HTTP_X_FORWARDED_PROTO \$scheme;
    }

    # PHP handling
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass statamic-app-$SITE_NUMBER;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param HTTP_X_FORWARDED_FOR \$proxy_add_x_forwarded_for;
        fastcgi_param HTTP_X_FORWARDED_PROTO \$scheme;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Deny access to sensitive files
    location ~* \.(env|log|htaccess|htpasswd)$ {
        deny all;
    }
}
EOF

echo "✅ Nginx configuration created: nginx/conf.d/${DOMAIN}.conf"

# Create site directory
mkdir -p "sites/$SITE_NAME/public"
echo "✅ Site directory created: sites/$SITE_NAME/"

# Update docker-compose.yml to add new service
echo ""
echo "⚠️  Manual steps required:"
echo "1. Add a new service 'statamic-app-$SITE_NUMBER' to docker-compose.yml"
echo "2. Add upstream 'statamic_app_$SITE_NUMBER' to nginx/nginx.conf"
echo "3. Update .env file with new site variables"
echo "4. Run: docker-compose up -d"
echo ""
echo "🎉 Domain $DOMAIN is ready for configuration!"
