# Statamic Multisite Docker Infrastructure

A complete Docker setup for running multiple Statamic sites with different domains, databases, and reverse proxy configuration.

## 🏗️ Architecture

This setup includes:

- **Nginx Reverse Proxy**: Routes traffic to different Statamic applications based on domain
- **Multiple Databases**: MySQL and MariaDB instances for different sites
- **phpMyAdmin**: Web interface for database management
- **Redis**: Caching layer for improved performance
- **Mailhog**: Email testing tool
- **Statamic Applications**: Containerized Statamic sites

## 📁 Project Structure

```
docker-statamic/
├── docker-compose.yml          # Main Docker Compose configuration
├── env.example                 # Environment variables template
├── setup.sh                   # Automated setup script
├── nginx/
│   ├── nginx.conf             # Main Nginx configuration
│   └── conf.d/
│       ├── site1.local.conf   # Site 1 domain configuration
│       └── site2.local.conf   # Site 2 domain configuration
├── statamic-app/
│   ├── Dockerfile             # Statamic application container
│   ├── nginx.conf             # Internal Nginx configuration
│   └── supervisord.conf       # Process management
├── mysql/
│   └── init/
│       └── 01-create-databases.sql
├── mariadb/
│   └── init/
│       └── 01-create-databases.sql
└── sites/
    ├── site1/                 # Site 1 files
    └── site2/                 # Site 2 files
```

## 🚀 Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd /home/amaury/devweb/docker-statamic
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

3. **Access your sites:**
   - Site 1: http://site1.local
   - Site 2: http://site2.local
   - phpMyAdmin: http://localhost:8080
   - Mailhog: http://localhost:8025

## 🔧 Manual Setup

If you prefer to set up manually:

1. **Copy environment file:**
   ```bash
   cp env.example .env
   ```

2. **Edit the .env file** with your configuration

3. **Add domains to /etc/hosts:**
   ```bash
   echo "127.0.0.1 site1.local www.site1.local" | sudo tee -a /etc/hosts
   echo "127.0.0.1 site2.local www.site2.local" | sudo tee -a /etc/hosts
   ```

4. **Start the services:**
   ```bash
   docker-compose up -d --build
   ```

5. **Install Statamic in each site:**
   ```bash
   docker-compose exec statamic-app-1 statamic new /var/www/html --force
   docker-compose exec statamic-app-2 statamic new /var/www/html --force
   ```

## 🌐 Adding New Sites

To add a new site:

1. **Add a new service to docker-compose.yml:**
   ```yaml
   statamic-app-3:
     build:
       context: ./statamic-app
       dockerfile: Dockerfile
     container_name: statamic-app-3
     environment:
       APP_NAME: "Statamic Site 3"
       APP_URL: ${SITE3_URL:-http://site3.local}
       # ... other environment variables
     volumes:
       - ./sites/site3:/var/www/html
     networks:
       - statamic-network
   ```

2. **Create Nginx configuration:**
   ```bash
   cp nginx/conf.d/site1.local.conf nginx/conf.d/site3.local.conf
   # Edit the new file for site3.local
   ```

3. **Update the main Nginx configuration** to include the new upstream

4. **Add domain to /etc/hosts:**
   ```bash
   echo "127.0.0.1 site3.local www.site3.local" | sudo tee -a /etc/hosts
   ```

5. **Restart services:**
   ```bash
   docker-compose up -d
   ```

## 🗄️ Database Management

### MySQL (Port 3306)
- **Root Password**: `rootpassword` (change in .env)
- **Databases**: `statamic_main`, `statamic_site1`, `statamic_site2`
- **phpMyAdmin**: http://localhost:8080

### MariaDB (Port 3307)
- **Root Password**: `rootpassword` (change in .env)
- **Databases**: `statamic_secondary`, `statamic_site3`, `statamic_site4`

## 🔧 Useful Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f statamic-app-1

# Access container shell
docker-compose exec statamic-app-1 bash
docker-compose exec mysql bash

# Restart specific service
docker-compose restart statamic-app-1

# Rebuild and start
docker-compose up -d --build

# Remove all containers and volumes
docker-compose down -v
```

## 🔒 Security Considerations

1. **Change default passwords** in the .env file
2. **Use SSL certificates** for production (add to nginx/ssl/)
3. **Restrict database access** by removing port mappings
4. **Use environment-specific configurations**

## 🐛 Troubleshooting

### Site not accessible
- Check if domain is in /etc/hosts
- Verify Nginx configuration
- Check container logs: `docker-compose logs nginx`

### Database connection issues
- Ensure databases are running: `docker-compose ps`
- Check database logs: `docker-compose logs mysql`
- Verify connection strings in .env

### Permission issues
- Check file permissions: `ls -la sites/site1/`
- Fix permissions: `sudo chown -R 1000:1000 sites/`

## 📝 Environment Variables

Key environment variables in `.env`:

```bash
# Site URLs
SITE1_URL=http://site1.local
SITE2_URL=http://site2.local

# Database passwords
MYSQL_ROOT_PASSWORD=rootpassword
MARIADB_ROOT_PASSWORD=rootpassword

# Application keys (auto-generated)
APP_KEY_1=base64:...
APP_KEY_2=base64:...
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
