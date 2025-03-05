-- Set the root password (if needed)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_root_password';

-- Create the XDMoD database
CREATE DATABASE IF NOT EXISTS xdmod;

-- Create the XDMoD user and grant privileges
CREATE USER 'xdmod_user'@'localhost' IDENTIFIED BY 'your_xdmod_password';
GRANT ALL PRIVILEGES ON xdmod.* TO 'xdmod_user'@'localhost';
FLUSH PRIVILEGES;
