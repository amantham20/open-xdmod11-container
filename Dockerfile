# Use Rocky Linux 8 as the base image
FROM rockylinux:8

# Set an environment variable for the XDMoD version
ENV XDMOD_VERSION=11.0.0

# Install EPEL and update the system
RUN dnf install -y epel-release && dnf update -y

# Reset and enable the PHP 7.4 module (XDMoD 11 does not support PHP 8)
RUN dnf module reset -y php && dnf module enable -y php:7.4

# Reset and install Node.js 16 as required
RUN dnf module reset -y nodejs && dnf module install -y nodejs:16

# Install all required dependencies.
# This includes Apache (httpd), MariaDB, PHP and its extensions,
# Node.js, libreoffice-writer, chromium-headless, and additional tools.
RUN dnf install -y epel-release
RUN dnf install -y httpd mariadb-server mariadb \
               php php-cli php-common php-pdo php-mysqlnd php-gd php-curl php-xml php-mbstring php-pecl-apcu \
               nodejs libreoffice-writer chromium-headless librsvg2 perl-Image-ExifTool cronie logrotate postfix jq


# Install SLURM and its dependencies.
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled powertools
RUN dnf install -y slurm munge munge-devel

# Copy the Open XDMoD RPM into the container.
# (Ensure the RPM file is in your build context with the expected name.)
COPY xdmod-${XDMOD_VERSION}-1.0.el8.noarch.rpm /tmp/xdmod.rpm

COPY xdmod-${XDMOD_VERSION}-1.0.el8.noarch.rpm .

# RUN dnf install -y xdmod-11.0.0-1.0.el8.noarch.rpm
# RUN xdmod-setup

# Install the Open XDMoD RPM package.
RUN dnf install -y /tmp/xdmod.rpm && rm -f /tmp/xdmod.rpm

# Run the XDMoD setup.
RUN /usr/bin/xdmod-setup --non-interactive || echo "xdmod-setup requires further configuration"
#! NEED TO BE ADJUSTED TO NON-INTERACTIVE MODE or to be run in docker

RUN mkdir -p /etc/pki/tls/private /etc/pki/tls/certs


RUN openssl req -new -newkey rsa:2048 -nodes -x509 -days 365 \
-subj "/CN=localhost" \
-keyout /etc/pki/tls/private/localhost.key \
-out /etc/pki/tls/certs/localhost.crt

RUN ls -l /etc/pki/tls/certs/localhost.crt && \
    cat /etc/pki/tls/certs/localhost.crt | head -n 5


RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf



# Expose HTTP and HTTPS ports.
EXPOSE 80 443

# Copy the startup script into the image.
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# CMD ["/bin/bash"]
# Define the default command to run when the container starts.
CMD ["/usr/local/bin/start.sh"]
