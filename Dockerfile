# Use the official PHP image as a base
FROM php:7.4-apache

# Set timezone to Tehran and update package lists
RUN apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -o Acquire::Check-Valid-Until=false update
#    apt-get update --allow-releaseinfo-change --allow-releaseinfo-change-suite

# Set DNS server
#RUN echo "nameserver 10.202.10.202" > /etc/resolv.conf

# Install necessary packages including libuv and dependencies for DataStax C/C++ driver
RUN apt-get install -y \
    libpcre3-dev \
    libssl-dev \
    libgmp-dev \
    git \
    libz-dev \
    libtool \
    automake \
    cmake \
    wget \
    g++ \
    libuv1-dev \
    uuid-dev

# Install DataStax C/C++ driver dependencies
RUN apt-get install -y \
    libssl-dev \
    libuv1-dev \
    libgmp-dev

# Install DataStax C/C++ driver
RUN cd /usr/src && \
    git clone --depth=1 --recurse-submodules https://github.com/datastax/cpp-driver.git && \
    mkdir -p cpp-driver/build && \
    cd cpp-driver/build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Install Apache mod_rewrite
RUN a2enmod rewrite

# Install and configure the Cassandra driver
RUN mkdir -p /usr/src/php/ext && \
    cd /usr/src && \
    git clone --depth=1 --recurse-submodules https://github.com/datastax/php-driver.git && \
    cd php-driver && \
    git submodule update --init && \
    cd ext && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    docker-php-ext-enable cassandra

# Configure Apache to allow .htaccess overrides and enable mod_rewrite
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/000-default.conf

# Copy test PHP script to container
COPY test.php /var/www/html/test.php

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
