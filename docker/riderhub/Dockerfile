# RiderHub Flarum Lambda Container
FROM bref/php-81-fpm:2

# Install system dependencies
RUN yum update -y && \
    yum install -y git unzip curl && \
    yum clean all

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/task

# Copy composer files first for better caching
COPY composer.json composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copy application files
COPY . .

# Run post-install scripts
RUN composer run-script post-autoload-dump || true

# Create necessary directories
RUN mkdir -p storage/app storage/framework/cache storage/framework/sessions storage/framework/views storage/logs

# Set proper permissions
RUN chmod -R 755 /var/task && \
    chmod -R 777 storage

# Create .env file from example if it doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "APP_NAME=RiderHub" > .env; fi

# Set the handler
CMD ["lambda.php"]
