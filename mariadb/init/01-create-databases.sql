-- Create databases for Statamic multisite setup
CREATE DATABASE IF NOT EXISTS statamic_secondary;
CREATE DATABASE IF NOT EXISTS statamic_site3;
CREATE DATABASE IF NOT EXISTS statamic_site4;

-- Create users for each site
CREATE USER IF NOT EXISTS 'statamic_user'@'%' IDENTIFIED BY 'statamic_password';
CREATE USER IF NOT EXISTS 'site3_user'@'%' IDENTIFIED BY 'site3_password';
CREATE USER IF NOT EXISTS 'site4_user'@'%' IDENTIFIED BY 'site4_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON statamic_secondary.* TO 'statamic_user'@'%';
GRANT ALL PRIVILEGES ON statamic_site3.* TO 'site3_user'@'%';
GRANT ALL PRIVILEGES ON statamic_site4.* TO 'site4_user'@'%';

-- Grant permissions to root for all databases
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
