-- Create database for Statamic multisite setup
CREATE DATABASE IF NOT EXISTS statamic_multisite;

-- Create user for the application
CREATE USER IF NOT EXISTS 'statamic_user'@'%' IDENTIFIED BY 'statamic_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON statamic_multisite.* TO 'statamic_user'@'%';

-- Grant permissions to root for all databases
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
