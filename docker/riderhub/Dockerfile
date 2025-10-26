# RiderHub Flarum Lambda Container
FROM bref/php-81-fpm:2

# Install system dependencies
RUN yum update -y && \
    yum install -y git unzip && \
    yum clean all

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/task

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set proper permissions
RUN chmod -R 755 /var/task

# Create Lambda handler
COPY lambda.php /var/task/lambda.php

# Set the handler
CMD ["lambda.php"]
