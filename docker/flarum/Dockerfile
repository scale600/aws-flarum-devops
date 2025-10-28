# =============================================================================
# Flarum OSS Dockerfile for AWS Lambda
# =============================================================================
FROM bref/php-81-fpm:2

# Set working directory
WORKDIR /var/task

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy composer files first for better caching
COPY src/flarum/composer.json src/flarum/composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copy application files
COPY src/flarum/ .

# Set proper permissions
RUN chmod -R 755 /var/task && \
    chown -R 1000:1000 /var/task

# Create necessary directories
RUN mkdir -p storage/framework/sessions && \
    mkdir -p storage/framework/cache && \
    mkdir -p storage/framework/views && \
    mkdir -p storage/logs && \
    mkdir -p bootstrap/cache

# Set permissions for storage directories
RUN chmod -R 775 storage && \
    chmod -R 775 bootstrap/cache

# Create .env file with default values
RUN echo "APP_NAME=Flarum" > .env && \
    echo "APP_ENV=production" >> .env && \
    echo "APP_DEBUG=false" >> .env && \
    echo "APP_URL=https://localhost" >> .env && \
    echo "" >> .env && \
    echo "DB_CONNECTION=mysql" >> .env && \
    echo "DB_HOST=localhost" >> .env && \
    echo "DB_PORT=3306" >> .env && \
    echo "DB_DATABASE=flarum" >> .env && \
    echo "DB_USERNAME=flarum" >> .env && \
    echo "DB_PASSWORD=" >> .env && \
    echo "" >> .env && \
    echo "FILESYSTEM_DISK=s3" >> .env && \
    echo "AWS_DEFAULT_REGION=us-east-1" >> .env && \
    echo "AWS_BUCKET=" >> .env && \
    echo "" >> .env && \
    echo "SESSION_DRIVER=array" >> .env && \
    echo "CACHE_DRIVER=array" >> .env && \
    echo "QUEUE_CONNECTION=sync" >> .env

# Set the handler
CMD ["lambda.php"]

