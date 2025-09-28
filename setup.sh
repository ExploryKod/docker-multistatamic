#!/bin/bash

# Statamic Multisite Docker Setup Script
echo "🚀 Setting up Statamic Multisite Docker Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created. Please edit it with your configuration."
fi

# Generate application keys
echo "🔑 Generating application keys..."
APP_KEY_1=$(openssl rand -base64 32)
APP_KEY_2=$(openssl rand -base64 32)

# Update .env file with generated keys
sed -i "s/APP_KEY_1=.*/APP_KEY_1=base64:$APP_KEY_1/" .env
sed -i "s/APP_KEY_2=.*/APP_KEY_2=base64:$APP_KEY_2/" .env

echo "✅ Application keys generated and updated in .env file."

# Create site directories
echo "📁 Creating site directories..."
mkdir -p sites/site1/public
mkdir -p sites/site2/public

# Add domains to /etc/hosts if they don't exist
echo "🌐 Adding domains to /etc/hosts..."
if ! grep -q "site1.local" /etc/hosts; then
    echo "127.0.0.1 site1.local www.site1.local" | sudo tee -a /etc/hosts
fi

if ! grep -q "site2.local" /etc/hosts; then
    echo "127.0.0.1 site2.local www.site2.local" | sudo tee -a /etc/hosts
fi

echo "✅ Domains added to /etc/hosts."

# Build and start containers
echo "🐳 Building and starting Docker containers..."
docker-compose up -d --build

# Wait for databases to be ready
echo "⏳ Waiting for databases to be ready..."
sleep 30

# Install Statamic in each site
echo "📦 Installing Statamic in site1..."
docker-compose exec statamic-app-1 statamic new /var/www/html --force

echo "📦 Installing Statamic in site2..."
docker-compose exec statamic-app-2 statamic new /var/www/html --force

echo "🎉 Setup complete!"
echo ""
echo "📋 Access your sites:"
echo "   Site 1: http://site1.local"
echo "   Site 2: http://site2.local"
echo "   phpMyAdmin: http://localhost:8080"
echo "   Mailhog: http://localhost:8025"
echo ""
echo "🔧 Useful commands:"
echo "   docker-compose up -d          # Start all services"
echo "   docker-compose down           # Stop all services"
echo "   docker-compose logs -f        # View logs"
echo "   docker-compose exec statamic-app-1 bash  # Access site1 container"
echo "   docker-compose exec statamic-app-2 bash  # Access site2 container"
